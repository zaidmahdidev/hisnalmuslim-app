import 'package:shared_preferences/shared_preferences.dart';

/// Minimal persistent key/value storage used by every repository.
///
/// All app state is stored as JSON strings under versioned keys, so the
/// interface stays tiny and is trivial to fake in tests.
abstract interface class KeyValueStore {
  String? getString(String key);
  Future<void> setString(String key, String value);
  Future<void> remove(String key);
  Future<void> clear();
}

/// Production store backed by [SharedPreferencesWithCache]. Reads are
/// synchronous from the in-memory cache; writes persist asynchronously.
class PrefsKeyValueStore implements KeyValueStore {
  PrefsKeyValueStore._(this._prefs);

  final SharedPreferencesWithCache _prefs;

  static Future<PrefsKeyValueStore> create() async {
    final prefs = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(),
    );
    return PrefsKeyValueStore._(prefs);
  }

  @override
  String? getString(String key) => _prefs.getString(key);

  @override
  Future<void> setString(String key, String value) => _prefs.setString(key, value);

  @override
  Future<void> remove(String key) => _prefs.remove(key);

  @override
  Future<void> clear() => _prefs.clear();
}

/// In-memory store for tests and previews.
class MemoryKeyValueStore implements KeyValueStore {
  MemoryKeyValueStore([Map<String, String>? initial]) : _values = {...?initial};

  final Map<String, String> _values;

  Map<String, String> get values => Map.unmodifiable(_values);

  @override
  String? getString(String key) => _values[key];

  @override
  Future<void> setString(String key, String value) async => _values[key] = value;

  @override
  Future<void> remove(String key) async => _values.remove(key);

  @override
  Future<void> clear() async => _values.clear();
}
