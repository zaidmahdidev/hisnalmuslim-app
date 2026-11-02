import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../data/models/dhikr.dart';

/// Favorite ids, newest first.
final favoritesProvider = NotifierProvider<FavoritesController, List<String>>(
  FavoritesController.new,
);

/// Favorites resolved to content items (ids missing from content are skipped).
final favoriteItemsProvider = Provider<List<Dhikr>>((ref) {
  final ids = ref.watch(favoritesProvider);
  return ref.watch(contentRepositoryProvider).resolve(ids);
});

final isFavoriteProvider = Provider.family<bool, String>(
  (ref, id) => ref.watch(favoritesProvider).contains(id),
);

class FavoritesController extends Notifier<List<String>> {
  @override
  List<String> build() => ref.read(favoritesRepositoryProvider).load();

  bool contains(String id) => state.contains(id);

  /// Returns true if the item is now a favorite.
  Future<bool> toggle(String id) async {
    final adding = !state.contains(id);
    state = adding ? [id, ...state] : [...state.where((e) => e != id)];
    await ref.read(favoritesRepositoryProvider).save(state);
    return adding;
  }

  /// Re-inserts a removed favorite at its previous position (undo).
  Future<void> restore(String id, int index) async {
    if (state.contains(id)) return;
    final next = [...state]..insert(index.clamp(0, state.length), id);
    state = next;
    await ref.read(favoritesRepositoryProvider).save(state);
  }

  void reload() => state = ref.read(favoritesRepositoryProvider).load();
}
