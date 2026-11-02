import 'package:flutter_test/flutter_test.dart';
import 'package:hisn_almuslim_app/core/storage/key_value_store.dart';
import 'package:hisn_almuslim_app/data/models/adhkar_category.dart';
import 'package:hisn_almuslim_app/features/adhkar/application/progress_controller.dart';
import 'package:hisn_almuslim_app/features/favorites/application/favorites_controller.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('ProgressController', () {
    test('increments up to the prescribed repeat count only', () {
      final container = makeContainer();
      addTearDown(container.dispose);
      final repo = loadContent();
      final dhikr = repo.itemsOf(CategoryIds.morning).firstWhere((d) => d.repeat == 3);
      final ctrl = container.read(progressProvider.notifier);

      expect(ctrl.increment(dhikr), 1);
      expect(ctrl.increment(dhikr), 2);
      expect(ctrl.increment(dhikr), 3);
      expect(ctrl.increment(dhikr), 3);
      expect(container.read(progressProvider).countOf(dhikr.id), 3);

      ctrl.resetItem(dhikr);
      expect(container.read(progressProvider).countOf(dhikr.id), 0);
    });

    test('records category completion and the streak', () {
      final clock = TestClock(DateTime(2026, 6, 1, 7));
      final container = makeContainer(clock: clock);
      addTearDown(container.dispose);
      final ctrl = container.read(progressProvider.notifier);
      final items = loadContent().itemsOf(CategoryIds.morning);

      for (final d in items.skip(1)) {
        ctrl.markComplete(d);
      }
      expect(container.read(categoryProgressProvider(CategoryIds.morning)).isDone, isFalse);
      expect(container.read(streakProvider), 0);

      ctrl.markComplete(items.first);
      final progress = container.read(categoryProgressProvider(CategoryIds.morning));
      expect(progress.isDone, isTrue);
      expect(progress.completed, items.length);
      expect(container.read(progressProvider).isCategoryCompleted(CategoryIds.morning), isTrue);
      expect(container.read(streakProvider), 1);

      // Un-completing an item removes today's completion again.
      ctrl.resetItem(items.first);
      expect(container.read(progressProvider).isCategoryCompleted(CategoryIds.morning), isFalse);
    });

    test('starts a fresh day but keeps history', () {
      final clock = TestClock(DateTime(2026, 6, 1, 7));
      final container = makeContainer(clock: clock);
      addTearDown(container.dispose);
      final ctrl = container.read(progressProvider.notifier);
      for (final d in loadContent().itemsOf(CategoryIds.morning)) {
        ctrl.markComplete(d);
      }
      ctrl.setPosition(CategoryIds.morning, 5);

      clock.now = DateTime(2026, 6, 2, 6);
      ctrl.refreshDay();
      final state = container.read(progressProvider);
      expect(state.dayKey, '2026-06-02');
      expect(state.counts, isEmpty);
      expect(state.positions, isEmpty);
      expect(container.read(streakProvider), 1, reason: 'yesterday still counts');
    });

    test('persists across app restarts', () {
      final store = MemoryKeyValueStore();
      final first = makeContainer(store: store);
      final dhikr = loadContent().itemsOf(CategoryIds.sleep).first;
      first.read(progressProvider.notifier).increment(dhikr);
      first.read(progressProvider.notifier).setPosition(CategoryIds.sleep, 2);
      first.dispose();

      final second = makeContainer(store: store);
      addTearDown(second.dispose);
      expect(second.read(progressProvider).countOf(dhikr.id), 1);
      expect(second.read(progressProvider.notifier).positionOf(CategoryIds.sleep), 2);
    });
  });

  group('FavoritesController', () {
    test('toggles, orders newest first, persists and restores', () async {
      final store = MemoryKeyValueStore();
      final container = makeContainer(store: store);
      final ctrl = container.read(favoritesProvider.notifier);
      final items = loadContent().itemsOf(CategoryIds.evening);

      expect(await ctrl.toggle(items[0].id), isTrue);
      expect(await ctrl.toggle(items[1].id), isTrue);
      expect(container.read(favoritesProvider), [items[1].id, items[0].id]);
      expect(container.read(isFavoriteProvider(items[0].id)), isTrue);
      expect(container.read(favoriteItemsProvider), [items[1], items[0]]);

      expect(await ctrl.toggle(items[1].id), isFalse);
      await ctrl.restore(items[1].id, 0);
      expect(container.read(favoritesProvider).first, items[1].id);
      container.dispose();

      final reopened = makeContainer(store: store);
      addTearDown(reopened.dispose);
      expect(reopened.read(favoritesProvider), [items[1].id, items[0].id]);
    });

    test('favorites pseudo-category progress follows the favorites list', () async {
      final container = makeContainer();
      addTearDown(container.dispose);
      final dhikr = loadContent().itemsOf(CategoryIds.waking).first;
      await container.read(favoritesProvider.notifier).toggle(dhikr.id);
      expect(container.read(categoryProgressProvider(CategoryIds.favorites)).total, 1);
      container.read(progressProvider.notifier).markComplete(dhikr);
      expect(container.read(categoryProgressProvider(CategoryIds.favorites)).isDone, isTrue);
    });
  });
}
