import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skypulse/models/weather_model.dart';

/// A value together with how fresh it is.
///
/// [cachedAt] is null when the value came straight from the network. When it is
/// set, the data was served from the offline cache and the UI says so rather
/// than passing old weather off as current — the same rule as #1: never present
/// something as true when it isn't.
class Cached<T> {
  const Cached.fresh(this.data) : cachedAt = null;
  const Cached.stale(this.data, this.cachedAt);

  final T data;
  final DateTime? cachedAt;

  bool get isStale => cachedAt != null;
}

/// The oldest cache timestamp among [entries], or null when every one is fresh.
///
/// The screen shows a single offline banner for several results that can fall
/// back independently — current weather might come from the network while the
/// forecast comes from cache. Taking the oldest means the banner never claims
/// the data is fresher than its stalest part.
DateTime? stalestAmong(Iterable<Cached<Object?>> entries) {
  final times = entries.map((e) => e.cachedAt).whereType<DateTime>().toList();
  if (times.isEmpty) return null;
  return times.reduce((a, b) => a.isBefore(b) ? a : b);
}

/// Stores the last successful weather response per location, so the app has
/// something to show when the network is gone.
class WeatherCache {
  WeatherCache(this._prefs);

  final SharedPreferences _prefs;

  /// Coordinates are rounded so tiny GPS jitter still hits the same entry;
  /// ~2 decimal places is roughly a kilometre, well within one city.
  static String _key(String kind, double lat, double lon) =>
      'weather_cache_${kind}_${lat.toStringAsFixed(2)}_${lon.toStringAsFixed(2)}';

  Future<void> saveCurrent(double lat, double lon, Weather weather) {
    return _write(_key('current', lat, lon), weather.toCacheJson());
  }

  Future<void> saveForecast(double lat, double lon, List<Weather> forecast) {
    return _write(
      _key('forecast', lat, lon),
      forecast.map((w) => w.toCacheJson()).toList(),
    );
  }

  Cached<Weather>? readCurrent(double lat, double lon) {
    return _read(_key('current', lat, lon), (data) {
      return Weather.fromCacheJson(data as Map<String, dynamic>);
    });
  }

  Cached<List<Weather>>? readForecast(double lat, double lon) {
    return _read(_key('forecast', lat, lon), (data) {
      return (data as List<dynamic>)
          .map((e) => Weather.fromCacheJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  Future<void> _write(String key, Object payload) {
    return _prefs.setString(
      key,
      jsonEncode({
        'savedAt': DateTime.now().millisecondsSinceEpoch,
        'data': payload,
      }),
    );
  }

  /// Returns null when there is nothing usable — absent, or unreadable because
  /// it was written by an older version. A bad entry is dropped rather than
  /// left to fail again on every launch.
  Cached<T>? _read<T>(String key, T Function(dynamic data) parse) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    try {
      final envelope = jsonDecode(raw) as Map<String, dynamic>;
      return Cached.stale(
        parse(envelope['data']),
        DateTime.fromMillisecondsSinceEpoch(envelope['savedAt'] as int),
      );
    } catch (_) {
      _prefs.remove(key);
      return null;
    }
  }
}
