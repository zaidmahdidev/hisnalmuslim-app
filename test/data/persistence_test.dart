import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisn_almuslim_app/core/storage/key_value_store.dart';
import 'package:hisn_almuslim_app/data/models/app_settings.dart';
import 'package:hisn_almuslim_app/data/models/reading_progress.dart';
import 'package:hisn_almuslim_app/data/models/reminder.dart';
import 'package:hisn_almuslim_app/data/repositories/favorites_repository.dart';
import 'package:hisn_almuslim_app/data/repositories/progress_repository.dart';
import 'package:hisn_almuslim_app/data/repositories/reminders_repository.dart';
import 'package:hisn_almuslim_app/data/repositories/settings_repository.dart';

void main() {
  late MemoryKeyValueStore store;

  setUp(() => store = MemoryKeyValueStore());

  group('SettingsRepository', () {
    test('returns defaults when nothing is stored', () {
      expect(SettingsRepository(store).load(), const AppSettings());
    });

    test('round-trips every field', () async {
      const settings = AppSettings(
        themeMode: ThemeMode.dark,
        languageCode: 'en',
        readingScale: 1.4,
        hapticsEnabled: false,
        soundEnabled: true,
        showTranslation: true,
        autoAdvance: false,
        tapTextToCount: false,
        onboardingDone: true,
      );
      await SettingsRepository(store).save(settings);
      expect(SettingsRepository(store).load(), settings);
    });

    test('ignores corrupt data and clamps out-of-range values', () async {
      await store.setString(SettingsRepository.key, '{not json');
      expect(SettingsRepository(store).load(), const AppSettings());
      await store.setString(
        SettingsRepository.key,
        '{"readingScale": 9, "languageCode": "fr", "themeMode": "neon"}',
      );
      final loaded = SettingsRepository(store).load();
      expect(loaded.readingScale, AppSettings.maxReadingScale);
      expect(loaded.languageCode, 'ar');
      expect(loaded.themeMode, ThemeMode.system);
    });
  });

  group('FavoritesRepository', () {
    test('round-trips ordered ids and skips invalid entries', () async {
      final repo = FavoritesRepository(store);
      expect(repo.load(), isEmpty);
      await repo.save(['b', 'a']);
      expect(FavoritesRepository(store).load(), ['b', 'a']);
      await store.setString(FavoritesRepository.key, '["x", 3, null]');
      expect(repo.load(), ['x']);
    });
  });

  group('ProgressRepository', () {
    test('keeps today\'s counts and drops them on a new day', () async {
      final repo = ProgressRepository(store);
      await repo.save(
        const ReadingProgress(
          dayKey: '2026-04-01',
          counts: {'hm75.am': 1},
          positions: {'morning': 3},
          history: {
            '2026-04-01': ['morning'],
          },
        ),
      );
      final same = repo.load('2026-04-01');
      expect(same.countOf('hm75.am'), 1);
      expect(same.positions['morning'], 3);

      final next = repo.load('2026-04-02');
      expect(next.counts, isEmpty);
      expect(next.positions, isEmpty);
      expect(next.isCategoryCompleted('morning', '2026-04-01'), isTrue);
    });

    test('streak counts consecutive completed days', () {
      const progress = ReadingProgress(
        dayKey: '2026-04-10',
        history: {
          '2026-04-07': ['morning'],
          '2026-04-08': ['evening'],
          '2026-04-09': ['morning', 'evening'],
          '2026-04-05': ['morning'],
        },
      );
      // Today not done yet: the streak still counts up to yesterday.
      expect(progress.streak({'morning', 'evening'}), 3);
      expect(progress.streak({'sleep'}), 0);
    });
  });

  group('RemindersRepository', () {
    test('always contains the three built-in reminders', () {
      final reminders = RemindersRepository(store).load();
      expect(reminders.map((r) => r.kind), [
        ReminderKind.morning,
        ReminderKind.evening,
        ReminderKind.sleep,
      ]);
      expect(reminders.every((r) => !r.enabled), isTrue);
    });

    test('merges saved built-ins and custom reminders', () async {
      final repo = RemindersRepository(store);
      await repo.save([
        Reminder.defaults.first.copyWith(enabled: true, hour: 5, minute: 45),
        const Reminder(id: 100, kind: ReminderKind.custom, hour: 9, minute: 0, title: 'ورد'),
      ]);
      final loaded = repo.load();
      expect(loaded.length, 4);
      expect(loaded.first.enabled, isTrue);
      expect(loaded.first.hour, 5);
      expect(loaded.last.title, 'ورد');
    });
  });
}
