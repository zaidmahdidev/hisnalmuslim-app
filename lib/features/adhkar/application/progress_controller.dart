import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/utils/day_key.dart';
import '../../../data/models/adhkar_category.dart';
import '../../../data/models/dhikr.dart';
import '../../../data/models/reading_progress.dart';
import '../../favorites/application/favorites_controller.dart';

final progressProvider = NotifierProvider<ProgressController, ReadingProgress>(
  ProgressController.new,
);

@immutable
class CategoryProgress {
  const CategoryProgress({required this.completed, required this.total});

  final int completed;
  final int total;

  double get ratio => total == 0 ? 0 : completed / total;
  bool get isDone => total > 0 && completed >= total;
  bool get isStarted => completed > 0;
}

/// Items to read for a category id (including the favorites pseudo-category).
final readingListProvider = Provider.family<List<Dhikr>, String>((ref, categoryId) {
  if (categoryId == CategoryIds.favorites) return ref.watch(favoriteItemsProvider);
  return ref.watch(contentRepositoryProvider).itemsOf(categoryId);
});

final categoryProgressProvider = Provider.family<CategoryProgress, String>((ref, categoryId) {
  final progress = ref.watch(progressProvider);
  final items = ref.watch(readingListProvider(categoryId));
  final done = items.where((d) => progress.countOf(d.id) >= d.repeat).length;
  return CategoryProgress(completed: done, total: items.length);
});

/// Categories that make up the daily "wird" and count towards the streak.
const dailyWirdCategories = {CategoryIds.morning, CategoryIds.evening};

final streakProvider = Provider<int>(
  (ref) => ref.watch(progressProvider).streak(dailyWirdCategories),
);

class ProgressController extends Notifier<ReadingProgress> {
  String get _today => DayKey.of(ref.read(clockProvider)());

  @override
  ReadingProgress build() => ref.read(progressRepositoryProvider).load(_today);

  /// Starts a fresh day if the date changed (called on resume and before writes).
  void refreshDay() {
    final next = state.forDay(_today);
    if (!identical(next, state)) {
      state = next;
      _save();
    }
  }

  /// Counts one repetition. Returns the new count (never above `repeat`).
  int increment(Dhikr dhikr) {
    refreshDay();
    final current = state.countOf(dhikr.id);
    if (current >= dhikr.repeat) return current;
    _setCount(dhikr, current + 1);
    return current + 1;
  }

  void markComplete(Dhikr dhikr) {
    refreshDay();
    _setCount(dhikr, dhikr.repeat);
  }

  void resetItem(Dhikr dhikr) {
    refreshDay();
    _setCount(dhikr, 0);
  }

  void setPosition(String categoryId, int index) {
    if (state.positions[categoryId] == index) return;
    state = state.copyWith(positions: {...state.positions, categoryId: index});
    _save();
  }

  int positionOf(String categoryId) => state.positions[categoryId] ?? 0;

  /// Clears today's counts, resume positions and the completion history.
  Future<void> resetAll() async {
    state = ReadingProgress(dayKey: _today);
    await ref.read(progressRepositoryProvider).clear();
  }

  void _setCount(Dhikr dhikr, int count) {
    final counts = {...state.counts};
    if (count <= 0) {
      counts.remove(dhikr.id);
    } else {
      counts[dhikr.id] = count;
    }
    var next = state.copyWith(counts: counts);
    next = _withCategoryCompletion(next, dhikr.categoryId);
    state = next;
    _save();
  }

  /// Records (or clears) today's completion of [categoryId] in the history.
  ReadingProgress _withCategoryCompletion(ReadingProgress progress, String categoryId) {
    final items = ref.read(contentRepositoryProvider).itemsOf(categoryId);
    if (items.isEmpty) return progress;
    final complete = items.every((d) => progress.countOf(d.id) >= d.repeat);
    final today = [...?progress.history[progress.dayKey]];
    final has = today.contains(categoryId);
    if (complete == has) return progress;
    complete ? today.add(categoryId) : today.remove(categoryId);
    final history = {...progress.history, progress.dayKey: today};
    if (today.isEmpty) history.remove(progress.dayKey);
    return progress.copyWith(history: _trim(history));
  }

  Map<String, List<String>> _trim(Map<String, List<String>> history) {
    if (history.length <= ReadingProgress.historyDays) return history;
    final keys = history.keys.toList()..sort();
    final keep = keys.sublist(keys.length - ReadingProgress.historyDays).toSet();
    return {
      for (final e in history.entries)
        if (keep.contains(e.key)) e.key: e.value,
    };
  }

  void _save() => ref.read(progressRepositoryProvider).save(state);
}
