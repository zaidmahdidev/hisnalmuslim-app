import 'package:flutter_test/flutter_test.dart';
import 'package:hisn_almuslim_app/core/storage/key_value_store.dart';
import 'package:hisn_almuslim_app/features/tasbeeh/application/tasbeeh_controller.dart';
import 'package:hisn_almuslim_app/features/tasbeeh/domain/tasbeeh_presets.dart';

import '../helpers/test_helpers.dart';

void main() {
  test('starts on the first preset with its default target', () {
    final container = makeContainer();
    addTearDown(container.dispose);
    final state = container.read(tasbeehProvider);
    expect(state.selectedId, tasbeehPresets.first.id);
    expect(state.target, 33);
    expect(state.count, 0);
  });

  test('counts reliably and wraps into a new round at the target', () {
    final container = makeContainer();
    addTearDown(container.dispose);
    final ctrl = container.read(tasbeehProvider.notifier);

    for (var i = 0; i < 32; i++) {
      expect(ctrl.increment(), TasbeehTick.counted);
    }
    expect(container.read(tasbeehProvider).count, 32);
    expect(ctrl.increment(), TasbeehTick.roundCompleted);

    final state = container.read(tasbeehProvider);
    expect(state.count, 0);
    expect(state.rounds, 1);
    expect(state.todayCount, 33);
    expect(state.totalCount, 33);
    expect(state.totals[tasbeehPresets.first.id], 33);
  });

  test('unlimited target never wraps', () {
    final container = makeContainer();
    addTearDown(container.dispose);
    final ctrl = container.read(tasbeehProvider.notifier)..setTarget(0);
    for (var i = 0; i < 250; i++) {
      expect(ctrl.increment(), TasbeehTick.counted);
    }
    expect(container.read(tasbeehProvider).count, 250);
    expect(container.read(tasbeehProvider).progress, 0);
  });

  test('lowering the target below the count resets the count', () {
    final container = makeContainer();
    addTearDown(container.dispose);
    final ctrl = container.read(tasbeehProvider.notifier)..setTarget(100);
    for (var i = 0; i < 50; i++) {
      ctrl.increment();
    }
    ctrl.setTarget(33);
    expect(container.read(tasbeehProvider).count, 0);
  });

  test('reset clears count and rounds but keeps statistics', () {
    final container = makeContainer();
    addTearDown(container.dispose);
    final ctrl = container.read(tasbeehProvider.notifier);
    for (var i = 0; i < 40; i++) {
      ctrl.increment();
    }
    ctrl.reset();
    final state = container.read(tasbeehProvider);
    expect(state.count, 0);
    expect(state.rounds, 0);
    expect(state.totalCount, 40);
  });

  test('selecting a phrase applies its default target', () {
    final container = makeContainer();
    addTearDown(container.dispose);
    container.read(tasbeehProvider.notifier).select('astaghfirullah');
    final state = container.read(tasbeehProvider);
    expect(state.selectedId, 'astaghfirullah');
    expect(state.target, 100);
    expect(container.read(selectedTasbeehProvider).text, contains('أَسْتَغْفِرُ'));
  });

  test('custom phrases can be added, selected and removed', () {
    final container = makeContainer();
    addTearDown(container.dispose);
    final ctrl = container.read(tasbeehProvider.notifier)..addCustom('  ذكر خاص  ', target: 7);
    var state = container.read(tasbeehProvider);
    final custom = state.customDhikr.single;
    expect(custom.text, 'ذكر خاص');
    expect(state.selectedId, custom.id);
    expect(state.target, 7);
    expect(container.read(tasbeehOptionsProvider).last.id, custom.id);

    ctrl
      ..addCustom('   ')
      ..removeCustom(custom.id);
    state = container.read(tasbeehProvider);
    expect(state.customDhikr, isEmpty);
    expect(state.selectedId, tasbeehPresets.first.id);
  });

  test('state survives a restart and today\'s count resets on a new day', () {
    final store = MemoryKeyValueStore();
    final clock = TestClock(DateTime(2026, 2, 1, 21));
    final first = makeContainer(store: store, clock: clock);
    final ctrl = first.read(tasbeehProvider.notifier);
    for (var i = 0; i < 10; i++) {
      ctrl.increment();
    }
    first.dispose();

    final second = makeContainer(store: store, clock: clock);
    expect(second.read(tasbeehProvider).count, 10);
    expect(second.read(tasbeehProvider).todayCount, 10);
    second.dispose();

    clock.now = DateTime(2026, 2, 2, 8);
    final third = makeContainer(store: store, clock: clock);
    addTearDown(third.dispose);
    final state = third.read(tasbeehProvider);
    expect(state.todayCount, 0);
    expect(state.totalCount, 10);
    expect(state.count, 10, reason: 'the current count is kept');
  });
}
