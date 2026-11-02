import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisn_almuslim_app/core/services/notification_service.dart';
import 'package:hisn_almuslim_app/core/storage/key_value_store.dart';
import 'package:hisn_almuslim_app/data/models/reminder.dart';
import 'package:hisn_almuslim_app/features/reminders/application/reminders_controller.dart';
import 'package:hisn_almuslim_app/features/settings/application/settings_controller.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../helpers/test_helpers.dart';

void main() {
  group('RemindersController', () {
    test('enabling asks for permission and schedules a localized daily reminder', () async {
      final scheduler = FakeReminderScheduler();
      final container = makeContainer(scheduler: scheduler);
      addTearDown(container.dispose);
      final ctrl = container.read(remindersProvider.notifier);
      final morning = container.read(remindersProvider).first;

      final result = await ctrl.setEnabled(morning, true);
      expect(result, ReminderEnableResult.enabled);
      expect(scheduler.permissionRequests, 1);
      final request = scheduler.scheduled[morning.id]!;
      expect(request.hour, 6);
      expect(request.minute, 30);
      expect(request.title, 'أذكار الصباح');
      expect(request.payload, '/read/morning');
    });

    test('does not ask again when notifications are already allowed', () async {
      final scheduler = FakeReminderScheduler(alreadyEnabled: true);
      final container = makeContainer(scheduler: scheduler);
      addTearDown(container.dispose);
      final evening = container.read(remindersProvider)[1];
      await container.read(remindersProvider.notifier).setEnabled(evening, true);
      expect(scheduler.permissionRequests, 0);
      expect(scheduler.scheduled.keys, [evening.id]);
    });

    test('denied permission leaves the reminder off', () async {
      final scheduler = FakeReminderScheduler(permissionGranted: false);
      final container = makeContainer(scheduler: scheduler);
      addTearDown(container.dispose);
      final sleep = container.read(remindersProvider)[2];
      final result = await container.read(remindersProvider.notifier).setEnabled(sleep, true);
      expect(result, ReminderEnableResult.permissionDenied);
      expect(container.read(remindersProvider)[2].enabled, isFalse);
      expect(scheduler.scheduled, isEmpty);
    });

    test('changing time reschedules; disabling cancels; state persists', () async {
      final store = MemoryKeyValueStore();
      final scheduler = FakeReminderScheduler();
      final container = makeContainer(store: store, scheduler: scheduler);
      final ctrl = container.read(remindersProvider.notifier);
      var morning = container.read(remindersProvider).first;
      await ctrl.setEnabled(morning, true);
      morning = container.read(remindersProvider).first;
      await ctrl.setTime(morning, const TimeOfDay(hour: 5, minute: 10));
      expect(scheduler.scheduled[morning.id]!.hour, 5);
      expect(scheduler.scheduled[morning.id]!.minute, 10);
      container.dispose();

      final reopened = makeContainer(store: store, scheduler: scheduler);
      addTearDown(reopened.dispose);
      final saved = reopened.read(remindersProvider).first;
      expect(saved.enabled, isTrue);
      expect(saved.hour, 5);
      await reopened.read(remindersProvider.notifier).setEnabled(saved, false);
      expect(scheduler.scheduled, isEmpty);
    });

    test('custom reminders get unique ids, a limit and English text', () async {
      final scheduler = FakeReminderScheduler();
      final container = makeContainer(scheduler: scheduler);
      addTearDown(container.dispose);
      await container.read(settingsProvider.notifier).setLanguage('en');
      final ctrl = container.read(remindersProvider.notifier);

      final first = await ctrl.addCustom('Quran', const TimeOfDay(hour: 20, minute: 0));
      final second = await ctrl.addCustom('', const TimeOfDay(hour: 21, minute: 0));
      expect(first!.id, Reminder.firstCustomId);
      expect(second!.id, Reminder.firstCustomId + 1);
      expect(first.enabled, isFalse, reason: 'enabled only after the permission check');

      await ctrl.setEnabled(second, true);
      expect(scheduler.scheduled[second.id]!.title, 'Hisn Al-Muslim');
      expect(scheduler.scheduled[second.id]!.channelName, 'Adhkar reminders');

      for (var i = 0; i < Reminder.maxCustom - 2; i++) {
        await ctrl.addCustom('r$i', const TimeOfDay(hour: 1, minute: 0));
      }
      expect(await ctrl.addCustom('one too many', const TimeOfDay(hour: 1, minute: 0)), isNull);

      await ctrl.remove(second);
      expect(scheduler.scheduled.containsKey(second.id), isFalse);
    });

    test('rescheduleAll restores every enabled reminder', () async {
      final scheduler = FakeReminderScheduler();
      final container = makeContainer(scheduler: scheduler);
      addTearDown(container.dispose);
      final ctrl = container.read(remindersProvider.notifier);
      for (final r in container.read(remindersProvider)) {
        await ctrl.setEnabled(r, true);
      }
      scheduler.scheduled.clear();
      await ctrl.rescheduleAll();
      expect(scheduler.scheduled.keys.toSet(), {1, 2, 3});
    });
  });

  test('requesting exact timing re-schedules enabled reminders', () async {
    final scheduler = FakeReminderScheduler(exactAllowed: false);
    final container = makeContainer(scheduler: scheduler);
    addTearDown(container.dispose);
    expect(await container.read(exactRemindersProvider.future), isFalse);
    final ctrl = container.read(remindersProvider.notifier);
    await ctrl.setEnabled(container.read(remindersProvider).first, true);
    scheduler.scheduled.clear();

    await ctrl.requestExactTiming();
    expect(scheduler.exactRequests, 1);
    expect(scheduler.scheduled.keys, [1]);
    expect(await container.read(exactRemindersProvider.future), isTrue);
  });

  group('LocalNotificationService.nextInstanceOf', () {
    setUpAll(tz_data.initializeTimeZones);

    test('returns today when the time is still ahead', () {
      final riyadh = tz.getLocation('Asia/Riyadh');
      final now = tz.TZDateTime(riyadh, 2026, 3, 10, 5);
      final next = LocalNotificationService.nextInstanceOf(now, 6, 30);
      expect(next, tz.TZDateTime(riyadh, 2026, 3, 10, 6, 30));
    });

    test('returns tomorrow when the time has passed (or is now)', () {
      final riyadh = tz.getLocation('Asia/Riyadh');
      final now = tz.TZDateTime(riyadh, 2026, 3, 10, 6, 30);
      final next = LocalNotificationService.nextInstanceOf(now, 6, 30);
      expect(next, tz.TZDateTime(riyadh, 2026, 3, 11, 6, 30));
    });

    test('handles month ends and DST transitions', () {
      final berlin = tz.getLocation('Europe/Berlin');
      final now = tz.TZDateTime(berlin, 2026, 3, 28, 23);
      final next = LocalNotificationService.nextInstanceOf(now, 6, 0);
      expect(next.day, 29);
      expect(next.hour, 6, reason: 'wall-clock time is kept across the DST switch');

      final endOfMonth = tz.TZDateTime(berlin, 2026, 4, 30, 23);
      final may = LocalNotificationService.nextInstanceOf(endOfMonth, 6, 0);
      expect((may.month, may.day), (5, 1));
    });
  });
}
