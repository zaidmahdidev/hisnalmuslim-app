import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/utils/day_key.dart';
import '../../../data/models/tasbeeh_state.dart';
import '../domain/tasbeeh_presets.dart';

final tasbeehProvider = NotifierProvider<TasbeehController, TasbeehState>(TasbeehController.new);

/// All selectable phrases: built-in presets followed by the user's own.
final tasbeehOptionsProvider = Provider<List<TasbeehDhikr>>(
  (ref) => [...tasbeehPresets, ...ref.watch(tasbeehProvider).customDhikr],
);

final selectedTasbeehProvider = Provider<TasbeehDhikr>((ref) {
  final id = ref.watch(tasbeehProvider.select((s) => s.selectedId));
  final options = ref.watch(tasbeehOptionsProvider);
  return options.firstWhere((d) => d.id == id, orElse: () => options.first);
});

enum TasbeehTick { counted, roundCompleted }

class TasbeehController extends Notifier<TasbeehState> {
  String get _today => DayKey.of(ref.read(clockProvider)());

  @override
  TasbeehState build() {
    final saved = ref.read(tasbeehRepositoryProvider).load();
    final initial =
        saved ??
        TasbeehState(
          selectedId: tasbeehPresets.first.id,
          dayKey: _today,
          target: tasbeehPresets.first.defaultTarget,
        );
    return _rolled(initial);
  }

  TasbeehState _rolled(TasbeehState s) =>
      s.dayKey == _today ? s : s.copyWith(dayKey: _today, todayCount: 0);

  void refreshDay() {
    final next = _rolled(state);
    if (!identical(next, state)) _set(next);
  }

  /// Counts once. When a round reaches its target the count wraps to zero
  /// and [TasbeehTick.roundCompleted] is returned.
  TasbeehTick increment() {
    var s = _rolled(state);
    final totals = {...s.totals, s.selectedId: (s.totals[s.selectedId] ?? 0) + 1};
    var count = s.count + 1;
    var rounds = s.rounds;
    var tick = TasbeehTick.counted;
    if (!s.unlimited && count >= s.target) {
      count = 0;
      rounds++;
      tick = TasbeehTick.roundCompleted;
    }
    s = s.copyWith(
      count: count,
      rounds: rounds,
      todayCount: s.todayCount + 1,
      totalCount: s.totalCount + 1,
      totals: totals,
    );
    _set(s);
    return tick;
  }

  /// Resets the current count and rounds (statistics are kept).
  void reset() => _set(state.copyWith(count: 0, rounds: 0));

  void select(String id) {
    if (id == state.selectedId) return;
    // Resolved from own state: reading tasbeehOptionsProvider here would be a
    // circular dependency (it watches this notifier).
    final options = [...tasbeehPresets, ...state.customDhikr];
    final dhikr = options.firstWhere((d) => d.id == id, orElse: () => options.first);
    _set(state.copyWith(selectedId: dhikr.id, count: 0, rounds: 0, target: dhikr.defaultTarget));
  }

  void setTarget(int target) {
    if (target == state.target) return;
    final count = target > 0 && state.count >= target ? 0 : state.count;
    _set(state.copyWith(target: target < 0 ? 0 : target, count: count));
  }

  /// Adds a user-defined phrase and selects it.
  void addCustom(String text, {int target = 33}) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final id = 'custom_${ref.read(clockProvider)().microsecondsSinceEpoch}';
    final dhikr = TasbeehDhikr(id: id, text: trimmed, defaultTarget: target, isCustom: true);
    _set(
      state.copyWith(
        customDhikr: [...state.customDhikr, dhikr],
        selectedId: id,
        count: 0,
        rounds: 0,
        target: target,
      ),
    );
  }

  void removeCustom(String id) {
    final custom = state.customDhikr.where((d) => d.id != id).toList();
    final selected = state.selectedId == id ? tasbeehPresets.first.id : state.selectedId;
    _set(
      state.copyWith(
        customDhikr: custom,
        selectedId: selected,
        count: state.selectedId == id ? 0 : state.count,
        rounds: state.selectedId == id ? 0 : state.rounds,
      ),
    );
  }

  void _set(TasbeehState next) {
    state = next;
    unawaited(ref.read(tasbeehRepositoryProvider).save(next));
  }
}
