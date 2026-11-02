import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/feedback_service.dart';
import '../core/services/notification_service.dart';
import '../core/storage/key_value_store.dart';
import '../data/repositories/content_repository.dart';
import '../data/repositories/favorites_repository.dart';
import '../data/repositories/progress_repository.dart';
import '../data/repositories/reminders_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../data/repositories/tasbeeh_repository.dart';
import '../features/settings/application/settings_controller.dart';

/// Infrastructure providers. The first three are overridden in `bootstrap`
/// (and in tests) with fully initialised instances.
final keyValueStoreProvider = Provider<KeyValueStore>(
  (ref) => throw UnimplementedError('keyValueStoreProvider must be overridden'),
);

final contentRepositoryProvider = Provider<ContentRepository>(
  (ref) => throw UnimplementedError('contentRepositoryProvider must be overridden'),
);

final reminderSchedulerProvider = Provider<ReminderScheduler>(
  (ref) => throw UnimplementedError('reminderSchedulerProvider must be overridden'),
);

/// Injectable clock so day-based logic is testable.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final settingsRepositoryProvider = Provider(
  (ref) => SettingsRepository(ref.watch(keyValueStoreProvider)),
);
final favoritesRepositoryProvider = Provider(
  (ref) => FavoritesRepository(ref.watch(keyValueStoreProvider)),
);
final progressRepositoryProvider = Provider(
  (ref) => ProgressRepository(ref.watch(keyValueStoreProvider)),
);
final tasbeehRepositoryProvider = Provider(
  (ref) => TasbeehRepository(ref.watch(keyValueStoreProvider)),
);
final remindersRepositoryProvider = Provider(
  (ref) => RemindersRepository(ref.watch(keyValueStoreProvider)),
);

/// Haptic/sound feedback configured from the current settings.
final feedbackProvider = Provider<FeedbackService>((ref) {
  final settings = ref.watch(settingsProvider);
  return FeedbackService(haptics: settings.hapticsEnabled, sound: settings.soundEnabled);
});
