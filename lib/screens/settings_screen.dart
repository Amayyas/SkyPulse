import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skypulse/l10n/app_localizations.dart';
import 'package:skypulse/providers/unit_provider.dart';
import 'package:skypulse/utils/unit_utils.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unit = ref.watch(unitProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              l10n.settingsUnitsTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: SegmentedButton<UnitSystem>(
              segments: [
                ButtonSegment(
                  value: UnitSystem.metric,
                  label: Text(l10n.settingsMetricLabel),
                  icon: const Icon(Icons.thermostat),
                ),
                ButtonSegment(
                  value: UnitSystem.imperial,
                  label: Text(l10n.settingsImperialLabel),
                  icon: const Icon(Icons.flag),
                ),
              ],
              selected: {unit},
              onSelectionChanged: (Set<UnitSystem> selection) {
                ref.read(unitProvider.notifier).setUnit(selection.first);
              },
            ),
          ),
          const Divider(height: 32),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              l10n.settingsPreviewTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.thermostat),
            title: Text(l10n.settingsTempPreview),
            trailing: Text(
              UnitConverter.formatTemperature(25, unit),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.air),
            title: Text(l10n.settingsWindPreview),
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
