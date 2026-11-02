import '../../core/storage/key_value_store.dart';
import '../models/tasbeeh_state.dart';
import 'json_storage.dart';

class TasbeehRepository with JsonStorage {
  TasbeehRepository(this.store);

  static const key = 'tasbeeh.v1';

  @override
  final KeyValueStore store;

  TasbeehState? load() {
    final json = readJson<Map<String, dynamic>>(key);
    if (json == null) return null;
    try {
      return TasbeehState.fromJson(json);
    } on Object {
      return null;
    }
  }

  Future<void> save(TasbeehState state) => writeJson(key, state.toJson());
}
