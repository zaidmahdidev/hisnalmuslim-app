import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hisn_almuslim_app/app/providers.dart';
import 'package:hisn_almuslim_app/core/services/notification_service.dart';
import 'package:hisn_almuslim_app/core/storage/key_value_store.dart';
import 'package:hisn_almuslim_app/data/datasources/content_asset_source.dart';
import 'package:hisn_almuslim_app/data/repositories/content_repository.dart';

ContentRepository? _content;

/// The real bundled content, parsed once per test run.
ContentRepository loadContent() => _content ??= ContentRepository(
  parseContent(File('assets/content/adhkar.json').readAsStringSync()),
);

/// Records scheduling calls instead of talking to the OS.
class FakeReminderScheduler implements ReminderScheduler {
  FakeReminderScheduler({
    this.permissionGranted = true,
    this.alreadyEnabled = false,
    this.exactAllowed = true,
  });

  bool permissionGranted;
  bool alreadyEnabled;
  bool exactAllowed;
  int exactRequests = 0;
  int permissionRequests = 0;
  final Map<int, DailyReminderRequest> scheduled = {};
  final StreamController<String> tapController = StreamController<String>.broadcast();

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> areNotificationsEnabled() async => alreadyEnabled;

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    return permissionGranted;
  }

  @override
  Future<void> scheduleDaily(DailyReminderRequest request) async => scheduled[request.id] = request;

  @override
  Future<bool> canScheduleExact() async => exactAllowed;

  @override
  Future<bool> requestExactPermission() async {
    exactRequests++;
    exactAllowed = true;
    return true;
  }

  @override
  Future<void> cancel(int id) async => scheduled.remove(id);

  @override
  Future<void> cancelAll() async => scheduled.clear();

  @override
  Stream<String> get taps => tapController.stream;

  @override
  Future<String?> launchRoute() async => null;
}

/// Mutable clock for day-rollover tests.
class TestClock {
  TestClock(this.now);

  DateTime now;

  DateTime call() => now;
}

/// A container wired like the real app, with in-memory infrastructure.
ProviderContainer makeContainer({
  MemoryKeyValueStore? store,
  FakeReminderScheduler? scheduler,
  TestClock? clock,
}) {
  final container = ProviderContainer(
    overrides: [
      keyValueStoreProvider.overrideWithValue(store ?? MemoryKeyValueStore()),
      contentRepositoryProvider.overrideWithValue(loadContent()),
      reminderSchedulerProvider.overrideWithValue(scheduler ?? FakeReminderScheduler()),
      if (clock != null) clockProvider.overrideWithValue(clock.call),
    ],
  );
  return container;
}
