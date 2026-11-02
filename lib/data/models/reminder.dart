import 'package:flutter/foundation.dart';

enum ReminderKind { morning, evening, sleep, custom }

/// A daily local reminder. [id] doubles as the notification id.
@immutable
class Reminder {
  const Reminder({
    required this.id,
    required this.kind,
    required this.hour,
    required this.minute,
    this.enabled = false,
    this.title = '',
  });

  factory Reminder.fromJson(Map<String, dynamic> json) => Reminder(
    id: json['id'] as int,
    kind: ReminderKind.values.asNameMap()[json['kind']] ?? ReminderKind.custom,
    hour: json['hour'] as int,
    minute: json['minute'] as int,
    enabled: json['enabled'] as bool? ?? false,
    title: json['title'] as String? ?? '',
  );

  /// Ids 1–3 are the built-in reminders; custom reminders start at 100.
  static const firstCustomId = 100;
  static const maxCustom = 10;

  static const defaults = [
    Reminder(id: 1, kind: ReminderKind.morning, hour: 6, minute: 30),
    Reminder(id: 2, kind: ReminderKind.evening, hour: 17, minute: 0),
    Reminder(id: 3, kind: ReminderKind.sleep, hour: 22, minute: 30),
  ];

  final int id;
  final ReminderKind kind;
  final int hour;
  final int minute;
  final bool enabled;

  /// User-written label (custom reminders only).
  final String title;

  bool get isCustom => kind == ReminderKind.custom;

  /// Deep link opened when the notification is tapped.
  String get route => switch (kind) {
    ReminderKind.morning => '/read/morning',
    ReminderKind.evening => '/read/evening',
    ReminderKind.sleep => '/read/sleep',
    ReminderKind.custom => '/home',
  };

  Reminder copyWith({int? hour, int? minute, bool? enabled, String? title}) => Reminder(
    id: id,
    kind: kind,
    hour: hour ?? this.hour,
    minute: minute ?? this.minute,
    enabled: enabled ?? this.enabled,
    title: title ?? this.title,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'kind': kind.name,
    'hour': hour,
    'minute': minute,
    'enabled': enabled,
    'title': title,
  };

  @override
  bool operator ==(Object other) =>
      other is Reminder &&
      other.id == id &&
      other.kind == kind &&
      other.hour == hour &&
      other.minute == minute &&
      other.enabled == enabled &&
      other.title == title;

  @override
  int get hashCode => Object.hash(id, kind, hour, minute, enabled, title);
}
