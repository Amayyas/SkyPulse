import 'dart:io';

/// Fails the build when line coverage drops below [_floor].
///
/// Generated files are excluded: `app_localizations_*.dart` is emitted by
/// gen-l10n and its uncovered lines are translations for strings no test
/// happens to render — counting them measures noise, not test quality.
const double _floor = 80.0;

const List<String> _excluded = ['l10n/app_localizations'];

void main() {
  final lcov = File('coverage/lcov.info');
  if (!lcov.existsSync()) {
    stderr.writeln(
      'coverage/lcov.info not found — run flutter test --coverage',
    );
    exit(1);
  }

  var file = '';
  var hit = 0;
  var found = 0;
  final perFile = <String, List<int>>{};

  for (final line in lcov.readAsLinesSync()) {
    if (line.startsWith('SF:')) {
      file = line.substring(3);
    } else if (line.startsWith('DA:') && file.isNotEmpty) {
      if (_excluded.any(file.contains)) continue;
      final covered = int.parse(line.substring(3).split(',')[1]) > 0;
      found++;
      if (covered) hit++;
      perFile.putIfAbsent(file, () => [0, 0]);
      perFile[file]![1]++;
      if (covered) perFile[file]![0]++;
    }
  }

  final pct = found == 0 ? 0.0 : 100 * hit / found;
  stdout.writeln('Line coverage: ${pct.toStringAsFixed(1)}% ($hit/$found)');

  if (pct < _floor) {
    final worst = perFile.entries.toList()
      ..sort(
        (a, b) => (a.value[0] / a.value[1]).compareTo(b.value[0] / b.value[1]),
      );
    stdout.writeln('\nLeast covered:');
    for (final e in worst.take(5)) {
      final p = 100 * e.value[0] / e.value[1];
      stdout.writeln('  ${p.toStringAsFixed(1).padLeft(5)}%  ${e.key}');
    }
    stderr.writeln(
      '\nCoverage ${pct.toStringAsFixed(1)}% is below the '
      '${_floor.toStringAsFixed(0)}% floor.',
    );
    exit(1);
  }
}
