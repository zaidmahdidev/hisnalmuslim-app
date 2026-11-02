import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../core/storage/key_value_store.dart';

/// Shared JSON helpers for repositories. Corrupt values are discarded
/// (and logged in debug builds) instead of crashing the app.
mixin JsonStorage {
  KeyValueStore get store;

  T? readJson<T>(String key) {
    final raw = store.getString(key);
    if (raw == null) return null;
    try {
      final value = jsonDecode(raw);
      return value is T ? value : null;
    } on FormatException catch (error) {
      debugPrint('Discarding corrupt value for $key: $error');
      return null;
    }
  }

  Future<void> writeJson(String key, Object value) => store.setString(key, jsonEncode(value));
}
