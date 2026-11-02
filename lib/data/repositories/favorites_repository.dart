import '../../core/storage/key_value_store.dart';
import 'json_storage.dart';

/// Favorite dhikr ids, most recently added first.
class FavoritesRepository with JsonStorage {
  FavoritesRepository(this.store);

  static const key = 'favorites.v1';

  @override
  final KeyValueStore store;

  List<String> load() => [
    for (final id in readJson<List<dynamic>>(key) ?? const <dynamic>[])
      if (id is String) id,
  ];

  Future<void> save(List<String> ids) => writeJson(key, ids);
}
