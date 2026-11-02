import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../app/providers.dart';
import '../../adhkar/application/progress_controller.dart';
import '../../favorites/application/favorites_controller.dart';
import '../../reminders/application/reminders_controller.dart';
import '../../tasbeeh/application/tasbeeh_controller.dart';
import 'settings_controller.dart';

final dataManagementProvider = Provider(DataManagement.new);

final appVersionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return '${info.version} (${info.buildNumber})';
});

/// Destructive user actions from Settings, kept out of the widgets.
class DataManagement {
  DataManagement(this._ref);

  final Ref _ref;

  Future<void> resetProgress() => _ref.read(progressProvider.notifier).resetAll();

  /// Deletes everything stored on the device and cancels all reminders.
  /// Every stateful provider is rebuilt from the now-empty store.
  Future<void> clearAll() async {
    await _ref.read(reminderSchedulerProvider).cancelAll();
    await _ref.read(keyValueStoreProvider).clear();
    _ref
      ..invalidate(settingsProvider)
      ..invalidate(favoritesProvider)
      ..invalidate(progressProvider)
      ..invalidate(tasbeehProvider)
      ..invalidate(remindersProvider);
  }
}
