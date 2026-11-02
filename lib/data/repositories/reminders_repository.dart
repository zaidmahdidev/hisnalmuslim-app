import '../../core/storage/key_value_store.dart';
import '../models/reminder.dart';
import 'json_storage.dart';

class RemindersRepository with JsonStorage {
  RemindersRepository(this.store);

  static const key = 'reminders.v1';

  @override
  final KeyValueStore store;

  /// Built-in reminders are always present (merged with saved values).
  List<Reminder> load() {
    final saved = <Reminder>[];
    for (final item in readJson<List<dynamic>>(key) ?? const <dynamic>[]) {
      try {
        saved.add(Reminder.fromJson(item as Map<String, dynamic>));
      } on Object {
        // Skip malformed entries.
      }
    }
    final byId = {for (final r in saved) r.id: r};
    return [
      for (final builtIn in Reminder.defaults) byId[builtIn.id] ?? builtIn,
      ...saved.where((r) => r.isCustom),
    ];
  }

  Future<void> save(List<Reminder> reminders) =>
      writeJson(key, [for (final r in reminders) r.toJson()]);
}
