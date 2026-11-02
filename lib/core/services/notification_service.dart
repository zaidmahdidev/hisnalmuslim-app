import 'dart:async';
import 'dart:ui' show Color;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Content of one scheduled daily reminder.
@immutable
class DailyReminderRequest {
  const DailyReminderRequest({
    required this.id,
    required this.hour,
    required this.minute,
    required this.title,
    required this.body,
    required this.payload,
    required this.channelName,
    required this.channelDescription,
  });

  final int id;
  final int hour;
  final int minute;
  final String title;
  final String body;

  /// In-app route opened when the notification is tapped.
  final String payload;
  final String channelName;
  final String channelDescription;
}

/// Platform-independent reminder scheduling API (faked in tests).
abstract interface class ReminderScheduler {
  Future<void> initialize();
  Future<bool> areNotificationsEnabled();

  /// Shows the OS permission prompt. Only call after explaining why.
  Future<bool> requestPermission();
  Future<void> scheduleDaily(DailyReminderRequest request);

  /// Whether reminders can fire at the exact minute. On Android 12+ this
  /// needs the user-granted "Alarms & reminders" access; elsewhere it is true.
  Future<bool> canScheduleExact();

  /// Opens the system screen to allow exact alarms (Android 14+).
  Future<bool> requestExactPermission();
  Future<void> cancel(int id);
  Future<void> cancelAll();

  /// Routes from notifications tapped while the app is running.
  Stream<String> get taps;

  /// Route of the notification that launched the app, if any.
  Future<String?> launchRoute();
}

/// [ReminderScheduler] backed by flutter_local_notifications.
///
/// Reminders are scheduled exactly when the system allows it
/// (`SCHEDULE_EXACT_ALARM`, user-revocable). Otherwise they fall back to
/// inexact alarms, which Android may defer by hours for far-away times — the
/// Reminders screen therefore offers the opt-in.
class LocalNotificationService implements ReminderScheduler {
  LocalNotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const channelId = 'adhkar_reminders';

  final FlutterLocalNotificationsPlugin _plugin;
  final StreamController<String> _taps = StreamController<String>.broadcast();
  Future<void>? _initialization;

  @override
  Stream<String> get taps => _taps.stream;

  @override
  Future<void> initialize() => _initialization ??= _initialize();

  Future<void> _initialize() async {
    // The full database is used on purpose: many Android devices report
    // legacy aliases (e.g. "Asia/Calcutta") that the smaller variants omit.
    tz_data.initializeTimeZones();
    try {
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone.identifier));
    } on Object catch (error) {
      // Unknown zone id: fall back to UTC offsets; times may shift by DST.
      debugPrint('Could not resolve local time zone: $error');
    }
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('ic_stat_hisn'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) _taps.add(payload);
      },
    );
  }

  @override
  Future<String?> launchRoute() async {
    await initialize();
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp ?? false) {
      return details!.notificationResponse?.payload;
    }
    return null;
  }

  @override
  Future<bool> areNotificationsEnabled() async {
    await initialize();
    if (defaultTargetPlatform == TargetPlatform.android) {
      return await _android?.areNotificationsEnabled() ?? false;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final options = await _ios?.checkPermissions();
      return options?.isEnabled ?? false;
    }
    return false;
  }

  @override
  Future<bool> requestPermission() async {
    await initialize();
    if (defaultTargetPlatform == TargetPlatform.android) {
      return await _android?.requestNotificationsPermission() ?? false;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return await _ios?.requestPermissions(alert: true, sound: true) ?? false;
    }
    return false;
  }

  @override
  Future<void> scheduleDaily(DailyReminderRequest request) async {
    await initialize();
    final exact = await canScheduleExact();
    try {
      await _schedule(
        request,
        exact ? AndroidScheduleMode.exactAllowWhileIdle : AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } on PlatformException catch (error) {
      // Exact access can be revoked between the check and the call.
      if (!exact) rethrow;
      debugPrint('Exact scheduling failed, using inexact: $error');
      await _schedule(request, AndroidScheduleMode.inexactAllowWhileIdle);
    }
  }

  Future<void> _schedule(DailyReminderRequest request, AndroidScheduleMode mode) {
    return _plugin.zonedSchedule(
      id: request.id,
      scheduledDate: nextInstanceOf(tz.TZDateTime.now(tz.local), request.hour, request.minute),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          request.channelName,
          channelDescription: request.channelDescription,
          icon: 'ic_stat_hisn',
          color: const Color(0xFF0E4D3A),
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: mode,
      title: request.title,
      body: request.body,
      payload: request.payload,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  @override
  Future<bool> canScheduleExact() async {
    await initialize();
    if (defaultTargetPlatform != TargetPlatform.android) return true;
    return await _android?.canScheduleExactNotifications() ?? false;
  }

  @override
  Future<bool> requestExactPermission() async {
    await initialize();
    if (defaultTargetPlatform != TargetPlatform.android) return true;
    return await _android?.requestExactAlarmsPermission() ?? false;
  }

  @override
  Future<void> cancel(int id) async {
    await initialize();
    await _plugin.cancel(id: id);
  }

  @override
  Future<void> cancelAll() async {
    await initialize();
    await _plugin.cancelAll();
  }

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  IOSFlutterLocalNotificationsPlugin? get _ios =>
      _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();

  /// The next moment (strictly after [now]) at [hour]:[minute] in [now]'s zone.
  @visibleForTesting
  static tz.TZDateTime nextInstanceOf(tz.TZDateTime now, int hour, int minute) {
    var scheduled = tz.TZDateTime(now.location, now.year, now.month, now.day, hour, minute);
    if (!scheduled.isAfter(now)) {
      scheduled = tz.TZDateTime(now.location, now.year, now.month, now.day + 1, hour, minute);
    }
    return scheduled;
  }
}
