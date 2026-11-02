import 'package:flutter/foundation.dart';

import '../../core/utils/day_key.dart';

/// Today's reading progress plus a compact completion history.
///
/// Counts and resume positions belong to a single local day and reset when
/// the day changes. The history keeps, per day, which categories were fully
/// completed (used for streaks), trimmed to [historyDays].
@immutable
class ReadingProgress {
  const ReadingProgress({
    required this.dayKey,
    this.counts = const {},
    this.positions = const {},
    this.history = const {},
  });

  factory ReadingProgress.fromJson(Map<String, dynamic> json) => ReadingProgress(
    dayKey: json['dayKey'] as String,
    counts: _intMap(json['counts']),
    positions: _intMap(json['positions']),
    history: {
      for (final e in ((json['history'] as Map<String, dynamic>?) ?? const {}).entries)
        e.key: [for (final c in e.value as List<dynamic>) c as String],
    },
  );

  static const historyDays = 120;

  final String dayKey;
  final Map<String, int> counts;
  final Map<String, int> positions;
  final Map<String, List<String>> history;

  int countOf(String dhikrId) => counts[dhikrId] ?? 0;

  bool isCategoryCompleted(String categoryId, [String? day]) =>
      history[day ?? dayKey]?.contains(categoryId) ?? false;

  /// Returns a copy for [today], clearing per-day data if the day changed.
  ReadingProgress forDay(String today) {
    if (today == dayKey) return this;
    return ReadingProgress(dayKey: today, history: history);
  }

  ReadingProgress copyWith({
    Map<String, int>? counts,
    Map<String, int>? positions,
    Map<String, List<String>>? history,
  }) => ReadingProgress(
    dayKey: dayKey,
    counts: counts ?? this.counts,
    positions: positions ?? this.positions,
    history: history ?? this.history,
  );

  /// Number of consecutive days (ending today, or yesterday if today has no
  /// completion yet) on which at least one of [categories] was completed.
  int streak(Set<String> categories) {
    bool completedOn(String day) => history[day]?.any(categories.contains) ?? false;
    var day = completedOn(dayKey) ? dayKey : DayKey.previous(dayKey);
    var streak = 0;
    while (completedOn(day)) {
      streak++;
      day = DayKey.previous(day);
    }
    return streak;
  }

  Map<String, dynamic> toJson() => {
    'dayKey': dayKey,
    'counts': counts,
    'positions': positions,
    'history': history,
  };

  static Map<String, int> _intMap(Object? value) => {
    for (final e in ((value as Map<String, dynamic>?) ?? const {}).entries)
      if (e.value is int) e.key: e.value as int,
  };
}
