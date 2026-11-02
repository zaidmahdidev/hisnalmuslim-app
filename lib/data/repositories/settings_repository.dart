import '../../core/storage/key_value_store.dart';
import '../models/app_settings.dart';
import 'json_storage.dart';

class SettingsRepository with JsonStorage {
  SettingsRepository(this.store);

  static const key = 'settings.v1';

  @override
  final KeyValueStore store;

  AppSettings load() {
    final json = readJson<Map<String, dynamic>>(key);
    return json == null ? const AppSettings() : AppSettings.fromJson(json);
  }

  Future<void> save(AppSettings settings) => writeJson(key, settings.toJson());
}
