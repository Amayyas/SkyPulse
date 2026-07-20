import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skypulse/utils/theme.dart';

/// The clock the theme reads. Injectable so tests can pin "now" instead of
/// depending on when they happen to run.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// The current time-of-day theme, kept live.
///
/// The old code computed the theme once at startup in a StatelessWidget that
/// never rebuilt, so the app stayed on whatever mood it launched in — the
/// "dynamic" theme wasn't. This recomputes at each hour boundary via a timer,
/// and on demand (used on app resume), and only pushes a new value when the
/// bucket actually changes, so watchers rebuild just at the six transitions.
class TimeOfDayThemeNotifier extends Notifier<TimeOfDayTheme> {
  Timer? _timer;

  @override
  TimeOfDayTheme build() {
    ref.onDispose(() => _timer?.cancel());
    _scheduleNextBoundary();
    return AppTheme.bucketForHour(_now().hour);
  }

  DateTime _now() => ref.read(clockProvider)();

  void _scheduleNextBoundary() {
    _timer?.cancel();
    final now = _now();
    // Re-check at the top of the next hour. Cheap, and the bucket only actually
    // changes at six of those boundaries — the rest are no-ops.
    final nextHour = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
    ).add(const Duration(hours: 1));
    _timer = Timer(nextHour.difference(now), () {
      refresh();
    });
  }

  /// Recompute now (e.g. the app came back from the background across a
  /// boundary) and reschedule.
  void refresh() {
    state = AppTheme.bucketForHour(_now().hour);
    _scheduleNextBoundary();
  }
}

final timeOfDayThemeProvider =
    NotifierProvider<TimeOfDayThemeNotifier, TimeOfDayTheme>(
      TimeOfDayThemeNotifier.new,
    );
