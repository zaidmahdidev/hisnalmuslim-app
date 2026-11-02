import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisn_almuslim_app/app/app.dart';
import 'package:hisn_almuslim_app/app/providers.dart';
import 'package:hisn_almuslim_app/app/router/app_router.dart';
import 'package:hisn_almuslim_app/core/storage/key_value_store.dart';
import 'package:hisn_almuslim_app/data/models/adhkar_category.dart';
import 'package:hisn_almuslim_app/data/models/app_settings.dart';
import 'package:hisn_almuslim_app/data/repositories/settings_repository.dart';
import 'package:hisn_almuslim_app/features/adhkar/application/progress_controller.dart';
import 'package:hisn_almuslim_app/features/adhkar/presentation/widgets/counter_button.dart';
import 'package:hisn_almuslim_app/features/favorites/application/favorites_controller.dart';
import 'package:hisn_almuslim_app/features/tasbeeh/application/tasbeeh_controller.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../helpers/test_helpers.dart';

MemoryKeyValueStore _store({bool onboarded = true, AppSettings? settings}) {
  final s = (settings ?? const AppSettings()).copyWith(onboardingDone: onboarded);
  return MemoryKeyValueStore({SettingsRepository.key: jsonEncode(s.toJson())});
}

Future<ProviderContainer> _pumpApp(
  WidgetTester tester, {
  required MemoryKeyValueStore store,
  Size size = const Size(390, 844),
}) async {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        keyValueStoreProvider.overrideWithValue(store),
        contentRepositoryProvider.overrideWithValue(loadContent()),
        reminderSchedulerProvider.overrideWithValue(FakeReminderScheduler()),
      ],
      child: const HisnApp(),
    ),
  );
  await tester.pumpAndSettle();
  return ProviderScope.containerOf(tester.element(find.byType(HisnApp)));
}

Future<void> _go(
  WidgetTester tester,
  ProviderContainer c,
  String location, {
  bool push = true,
}) async {
  final router = c.read(routerProvider);
  push ? router.push(location) : router.go(location);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() {
    PackageInfo.setMockInitialValues(
      appName: 'Hisn Al-Muslim',
      packageName: 'com.zaid.hisnalmuslim',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
  });

  testWidgets('first launch shows onboarding, then the home dashboard', (tester) async {
    await _pumpApp(tester, store: _store(onboarded: false));
    expect(find.text('حصن المسلم'), findsWidgets);
    await tester.tap(find.text('التالي'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('التالي'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ابدأ'));
    await tester.pumpAndSettle();

    expect(find.text('وِرد اليوم'), findsOneWidget);
    expect(find.text('مقترح الآن'), findsOneWidget);
    expect(find.text('ذكر اليوم'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('reader counts repetitions, completes and auto-advances', (tester) async {
    final c = await _pumpApp(tester, store: _store());
    await _go(tester, c, '/read/${CategoryIds.morning}');
    final items = loadContent().itemsOf(CategoryIds.morning);

    expect(find.text('1 من ${items.length}'), findsOneWidget);
    await tester.tap(find.byType(CounterButton));
    await tester.pump();
    expect(c.read(progressProvider).countOf(items[0].id), 1);

    // Auto-advance after completion.
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(find.text('2 من ${items.length}'), findsOneWidget);

    // Second item needs 3 taps; extra taps never exceed the count.
    expect(items[1].repeat, 3);
    for (var i = 0; i < 2; i++) {
      await tester.tap(find.byType(CounterButton));
      await tester.pump();
    }
    expect(c.read(progressProvider).countOf(items[1].id), 2);
    expect(c.read(categoryProgressProvider(CategoryIds.morning)).completed, 1);
  });

  testWidgets('favorite toggled in the reader appears in the Favorites tab', (tester) async {
    final c = await _pumpApp(tester, store: _store());
    await _go(tester, c, '/read/${CategoryIds.sleep}');
    await tester.tap(find.byTooltip('إضافة إلى المفضلة'));
    await tester.pumpAndSettle();
    final first = loadContent().itemsOf(CategoryIds.sleep).first;
    expect(c.read(favoritesProvider), [first.id]);

    c.read(routerProvider).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('المفضلة').last);
    await tester.pumpAndSettle();
    expect(find.text('قراءة الكل'), findsOneWidget);
    expect(find.byTooltip('إزالة من المفضلة'), findsOneWidget);
  });

  testWidgets('search finds adhkar offline and opens the reader', (tester) async {
    final c = await _pumpApp(tester, store: _store());
    await _go(tester, c, '/search');
    await tester.enterText(find.byType(TextField), 'السفر');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(find.textContaining('نتيج'), findsOneWidget);
    expect(find.text('دعاء السفر'), findsWidgets);

    await tester.enterText(find.byType(TextField), 'كلمةلاوجودلها');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(find.textContaining('لا نتائج'), findsOneWidget);
  });

  testWidgets('tasbeeh counts taps and keeps statistics', (tester) async {
    final c = await _pumpApp(tester, store: _store());
    await tester.tap(find.text('المسبحة').last);
    await tester.pumpAndSettle();
    final dial = find.bySemanticsLabel(RegExp('العدد'));
    for (var i = 0; i < 5; i++) {
      await tester.tap(dial);
      await tester.pump(const Duration(milliseconds: 20));
    }
    await tester.pumpAndSettle();
    expect(c.read(tasbeehProvider).count, 5);
    expect(find.text('5'), findsWidgets);
  });

  testWidgets('English UI is left-to-right', (tester) async {
    await _pumpApp(
      tester,
      store: _store(settings: const AppSettings(languageCode: 'en')),
    );
    expect(find.text('Home'), findsOneWidget);
    expect(Directionality.of(tester.element(find.text("Today's wird"))), TextDirection.ltr);
  });

  testWidgets('Arabic UI is right-to-left', (tester) async {
    await _pumpApp(tester, store: _store());
    expect(find.text('الرئيسية'), findsOneWidget);
    expect(Directionality.of(tester.element(find.text('وِرد اليوم'))), TextDirection.rtl);
  });

  testWidgets('dark theme is applied from settings', (tester) async {
    await _pumpApp(
      tester,
      store: _store(settings: const AppSettings(themeMode: ThemeMode.dark)),
    );
    final context = tester.element(find.text('وِرد اليوم'));
    expect(Theme.of(context).brightness, Brightness.dark);
  });

  testWidgets('clearing all data returns to onboarding with empty state', (tester) async {
    final store = _store();
    final c = await _pumpApp(tester, store: store);
    await c.read(favoritesProvider.notifier).toggle(loadContent().itemsOf('waking').first.id);

    await tester.tap(find.text('الإعدادات').last);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('مسح جميع بيانات التطبيق'), 300);
    await tester.tap(find.text('مسح جميع بيانات التطبيق'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('حذف'));
    await tester.pumpAndSettle();

    expect(find.text('تخطٍّ'), findsOneWidget);
    expect(store.values, isEmpty);
    expect(c.read(favoritesProvider), isEmpty);
  });

  testWidgets('200% system text size renders without overflow', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final c = await _pumpApp(tester, store: _store(), size: const Size(360, 780));
    for (final location in ['/library', '/tasbeeh', '/settings']) {
      await _go(tester, c, location, push: false);
    }
    await _go(tester, c, '/read/${CategoryIds.evening}');
    expect(tester.takeException(), isNull);
  });

  group('responsive layouts render without overflow', () {
    for (final (name, size) in [
      ('small phone', const Size(320, 568)),
      ('tablet', const Size(1024, 1366)),
    ]) {
      testWidgets(name, (tester) async {
        final c = await _pumpApp(tester, store: _store(), size: size);
        for (final location in ['/library', '/tasbeeh', '/favorites', '/settings']) {
          await _go(tester, c, location, push: false);
        }
        await _go(tester, c, '/library/prayer', push: false);
        await _go(tester, c, '/read/${CategoryIds.quranDuas}');
        await _go(tester, c, '/reminders');
        await _go(tester, c, '/about');
        expect(tester.takeException(), isNull);
      });
    }
  });
}
