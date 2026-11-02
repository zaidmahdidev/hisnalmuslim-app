import '../../core/storage/key_value_store.dart';
import '../models/reading_progress.dart';
import 'json_storage.dart';

class ProgressRepository with JsonStorage {
  ProgressRepository(this.store);

  static const key = 'progress.v1';

  @override
  final KeyValueStore store;

  ReadingProgress load(String today) {
    final json = readJson<Map<String, dynamic>>(key);
    if (json == null) return ReadingProgress(dayKey: today);
    try {
      return ReadingProgress.fromJson(json).forDay(today);
    } on Object {
      return ReadingProgress(dayKey: today);
    }
  }

  Future<void> save(ReadingProgress progress) => writeJson(key, progress.toJson());

  Future<void> clear() => store.remove(key);
}
