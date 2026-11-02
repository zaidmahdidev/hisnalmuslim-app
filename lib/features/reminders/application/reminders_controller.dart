import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/localization/gen/app_localizations.dart';
import '../../../app/providers.dart';
import '../../../core/services/notification_service.dart';
import '../../../data/models/reminder.dart';
import '../../settings/application/settings_controller.dart';

final remindersProvider = NotifierProvider<RemindersController, List<Reminder>>(
  RemindersController.new,
);

/// Whether reminders can be delivered at the exact minute (re-checked on
/// resume, since the user can change it in system settings).
final exactRemindersProvider = FutureProvider<bool>(
  (ref) => ref.watch(reminderSchedulerProvider).canScheduleExact(),
);

/// Result of trying to enable a reminder.
enum ReminderEnableResult { enabled, permissionDenied }

class RemindersController extends Notifier<List<Reminder>> {
  @override
  List<Reminder> build() => ref.read(remindersRepositoryProvider).load();

  ReminderScheduler get _scheduler => ref.read(reminderSchedulerProvider);

  bool get hasEnabled => state.any((r) => r.enabled);

  /// Turns a reminder on or off. The UI must have shown the permission
  /// rationale before calling this with `enabled: true` for the first time.
  Future<ReminderEnableResult> setEnabled(Reminder reminder, bool enabled) async {
    if (enabled) {
      final granted =
          await _scheduler.areNotificationsEnabled() || await _scheduler.requestPermission();
      if (!granted) return ReminderEnableResult.permissionDenied;
    }
    await _replace(reminder.copyWith(enabled: enabled));
    return ReminderEnableResult.enabled;
  }

  Future<void> setTime(Reminder reminder, TimeOfDay time) =>
      _replace(reminder.copyWith(hour: time.hour, minute: time.minute));

  Future<void> setTitle(Reminder reminder, String title) =>
      _replace(reminder.copyWith(title: title.trim()));

  /// Adds a custom reminder (disabled; enable it with [setEnabled] so the
  /// permission check runs). Returns null if the limit is reached.
  Future<Reminder?> addCustom(String title, TimeOfDay time) async {
    final custom = state.where((r) => r.isCustom).toList();
    if (custom.length >= Reminder.maxCustom) return null;
    final used = custom.map((r) => r.id).toSet();
    var id = Reminder.firstCustomId;
    while (used.contains(id)) {
      id++;
    }
    final reminder = Reminder(
      id: id,
      kind: ReminderKind.custom,
      hour: time.hour,
      minute: time.minute,
      title: title.trim(),
    );
    state = [...state, reminder];
    await _persistAndSync(reminder);
    return reminder;
  }

  Future<void> remove(Reminder reminder) async {
    state = state.where((r) => r.id != reminder.id).toList();
    await ref.read(remindersRepositoryProvider).save(state);
    await _scheduler.cancel(reminder.id);
  }

  /// Asks for exact timing, then re-schedules so existing reminders use it.
  Future<void> requestExactTiming() async {
    await _scheduler.requestExactPermission();
    await rescheduleAll();
    ref.invalidate(exactRemindersProvider);
  }

  /// Re-creates every enabled schedule (start-up and language changes).
  Future<void> rescheduleAll() async {
    for (final reminder in state) {
      await _sync(reminder);
    }
  }

  /// Cancels everything and restores the defaults (used by "clear data").
  Future<void> resetAll() async {
    await _scheduler.cancelAll();
    state = ref.read(remindersRepositoryProvider).load();
  }

  Future<void> _replace(Reminder reminder) async {
    state = [for (final r in state) r.id == reminder.id ? reminder : r];
    await _persistAndSync(reminder);
  }

  Future<void> _persistAndSync(Reminder reminder) async {
    await ref.read(remindersRepositoryProvider).save(state);
    await _sync(reminder);
  }

  Future<void> _sync(Reminder reminder) async {
    try {
      if (!reminder.enabled) {
        await _scheduler.cancel(reminder.id);
        return;
      }
      await _scheduler.scheduleDaily(requestFor(reminder));
    } on Object catch (error) {
      debugPrint('Reminder ${reminder.id} could not be scheduled: $error');
    }
  }

  /// Builds the notification content in the current app language.
  @visibleForTesting
  DailyReminderRequest requestFor(Reminder reminder) {
    final l10n = lookupAppLocalizations(ref.read(settingsProvider).locale);
    final (title, body) = switch (reminder.kind) {
      ReminderKind.morning => (l10n.reminderMorning, l10n.reminderMorningBody),
      ReminderKind.evening => (l10n.reminderEvening, l10n.reminderEveningBody),
      ReminderKind.sleep => (l10n.reminderSleep, l10n.reminderSleepBody),
      ReminderKind.custom => (
        reminder.title.isEmpty ? l10n.appName : reminder.title,
        l10n.reminderCustomBody,
      ),
    };
    return DailyReminderRequest(
      id: reminder.id,
      hour: reminder.hour,
      minute: reminder.minute,
      title: title,
      body: body,
      payload: reminder.route,
      channelName: l10n.reminderChannelName,
      channelDescription: l10n.reminderChannelDescription,
    );
  }
}
