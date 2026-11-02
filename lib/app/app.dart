import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/adhkar/application/progress_controller.dart';
import '../features/home/application/home_providers.dart';
import '../features/reminders/application/reminders_controller.dart';
import '../features/settings/application/settings_controller.dart';
import '../features/tasbeeh/application/tasbeeh_controller.dart';
import 'localization/gen/app_localizations.dart';
import 'providers.dart';
import 'router/app_router.dart';
import 'router/routes.dart';
import 'theme/app_theme.dart';

class HisnApp extends ConsumerStatefulWidget {
  const HisnApp({super.key});

  @override
  ConsumerState<HisnApp> createState() => _HisnAppState();
}

class _HisnAppState extends ConsumerState<HisnApp> {
  late final AppLifecycleListener _lifecycle;
  StreamSubscription<String>? _taps;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _onResume);
    WidgetsBinding.instance.addPostFrameCallback((_) => _afterFirstFrame());
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _taps?.cancel();
    super.dispose();
  }

  /// A new day may have started while the app was in the background.
  void _onResume() {
    ref.read(progressProvider.notifier).refreshDay();
    ref.read(tasbeehProvider.notifier).refreshDay();
    ref
      ..invalidate(dayPartProvider)
      ..invalidate(dailyDhikrProvider)
      ..invalidate(exactRemindersProvider);
    // Exact-alarm access may have changed in system settings.
    ref.read(remindersProvider.notifier).rescheduleAll();
  }

  Future<void> _afterFirstFrame() async {
    final scheduler = ref.read(reminderSchedulerProvider);
    _taps = scheduler.taps.listen(_openRoute);
    try {
      final launch = await scheduler.launchRoute();
      if (launch != null) _openRoute(launch);
      // Keep OS schedules in sync with saved reminders (e.g. after updates).
      await ref.read(remindersProvider.notifier).rescheduleAll();
    } on Object catch (error) {
      debugPrint('Notification setup failed: $error');
    }
  }

  /// Only routes produced by our own reminders are accepted.
  void _openRoute(String route) {
    if (!route.startsWith('/read/') && route != Routes.home) return;
    if (!ref.read(settingsProvider).onboardingDone) return;
    ref.read(routerProvider).push(route);
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      routerConfig: ref.watch(routerProvider),
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: settings.themeMode,
      locale: settings.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        // Honour system text scaling up to 200% so layouts stay usable.
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(textScaler: media.textScaler.clamp(maxScaleFactor: 2.0)),
          child: child!,
        );
      },
    );
  }
}
