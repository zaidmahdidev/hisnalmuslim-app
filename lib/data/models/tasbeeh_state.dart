import 'package:flutter/foundation.dart';

/// A phrase that can be counted on the digital tasbeeh.
@immutable
class TasbeehDhikr {
  const TasbeehDhikr({
    required this.id,
    required this.text,
    this.meaningEn = '',
    this.defaultTarget = 33,
    this.isCustom = false,
  });

  factory TasbeehDhikr.fromJson(Map<String, dynamic> json) => TasbeehDhikr(
    id: json['id'] as String,
    text: json['text'] as String,
    defaultTarget: json['defaultTarget'] as int? ?? 33,
    isCustom: true,
  );

  final String id;
  final String text;
  final String meaningEn;
  final int defaultTarget;
  final bool isCustom;

  Map<String, dynamic> toJson() => {'id': id, 'text': text, 'defaultTarget': defaultTarget};
}

/// Persistent tasbeeh state. A [target] of 0 means "no limit".
@immutable
class TasbeehState {
  const TasbeehState({
    required this.selectedId,
    required this.dayKey,
    this.count = 0,
    this.target = 33,
    this.rounds = 0,
    this.todayCount = 0,
    this.totalCount = 0,
    this.totals = const {},
    this.customDhikr = const [],
  });

  factory TasbeehState.fromJson(Map<String, dynamic> json) => TasbeehState(
    selectedId: json['selectedId'] as String,
    dayKey: json['dayKey'] as String,
    count: json['count'] as int? ?? 0,
    target: json['target'] as int? ?? 33,
    rounds: json['rounds'] as int? ?? 0,
    todayCount: json['todayCount'] as int? ?? 0,
    totalCount: json['totalCount'] as int? ?? 0,
    totals: {
      for (final e in ((json['totals'] as Map<String, dynamic>?) ?? const {}).entries)
        if (e.value is int) e.key: e.value as int,
    },
    customDhikr: [
      for (final c in (json['custom'] as List<dynamic>? ?? const []))
        TasbeehDhikr.fromJson(c as Map<String, dynamic>),
    ],
  );

  final String selectedId;
  final String dayKey;

  /// Count within the current round.
  final int count;
  final int target;

  /// Completed rounds for the selected dhikr since it was selected/reset.
  final int rounds;
  final int todayCount;
  final int totalCount;

  /// All-time count per dhikr id.
  final Map<String, int> totals;
  final List<TasbeehDhikr> customDhikr;

  bool get unlimited => target <= 0;
  double get progress => unlimited ? 0 : (count / target).clamp(0.0, 1.0);

  TasbeehState copyWith({
    String? selectedId,
    String? dayKey,
    int? count,
    int? target,
    int? rounds,
    int? todayCount,
    int? totalCount,
    Map<String, int>? totals,
    List<TasbeehDhikr>? customDhikr,
  }) => TasbeehState(
    selectedId: selectedId ?? this.selectedId,
    dayKey: dayKey ?? this.dayKey,
    count: count ?? this.count,
    target: target ?? this.target,
    rounds: rounds ?? this.rounds,
    todayCount: todayCount ?? this.todayCount,
    totalCount: totalCount ?? this.totalCount,
    totals: totals ?? this.totals,
    customDhikr: customDhikr ?? this.customDhikr,
  );

  Map<String, dynamic> toJson() => {
    'selectedId': selectedId,
    'dayKey': dayKey,
    'count': count,
    'target': target,
    'rounds': rounds,
    'todayCount': todayCount,
    'totalCount': totalCount,
    'totals': totals,
    'custom': [for (final c in customDhikr) c.toJson()],
  };
}
