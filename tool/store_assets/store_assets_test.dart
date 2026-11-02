// Renders Google Play / App Store graphics from the real app UI.
//
//   flutter test tool/store_assets --update-goldens
//
// Output: docs/release/store_assets/{screenshots,feature_graphic}/*.png
// Real fonts are loaded so Arabic is shaped exactly as on a device.
@Tags(['store-assets'])
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisn_almuslim_app/app/app.dart';
import 'package:hisn_almuslim_app/app/providers.dart';
import 'package:hisn_almuslim_app/app/router/app_router.dart';
import 'package:hisn_almuslim_app/app/theme/app_colors.dart';
import 'package:hisn_almuslim_app/core/storage/key_value_store.dart';
import 'package:hisn_almuslim_app/core/widgets/brand_mark.dart';
import 'package:hisn_almuslim_app/core/widgets/islamic_pattern.dart';
import 'package:hisn_almuslim_app/data/models/app_settings.dart';
import 'package:hisn_almuslim_app/data/repositories/settings_repository.dart';
import 'package:hisn_almuslim_app/features/adhkar/application/progress_controller.dart';
import 'package:hisn_almuslim_app/features/favorites/application/favorites_controller.dart';
import 'package:hisn_almuslim_app/features/tasbeeh/application/tasbeeh_controller.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../test/helpers/test_helpers.dart';

const _out = '../../docs/release/store_assets';

Future<void> _loadFonts() async {
  Future<void> load(String family, List<String> files) async {
    final loader = FontLoader(family);
    for (final f in files) {
      loader.addFont(Future.value(ByteData.sublistView(File(f).readAsBytesSync())));
    }
    await loader.load();
  }

  await load('IBMPlexSansArabic', [
    for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold'])
      'assets/fonts/IBMPlexSansArabic-$w.ttf',
  ]);
  await load('Amiri', ['assets/fonts/Amiri-Regular.ttf', 'assets/fonts/Amiri-Bold.ttf']);
  await load('AmiriQuran', ['assets/fonts/AmiriQuran-Regular.ttf']);
  final flutterRoot = Platform.environment['FLUTTER_ROOT']!;
  await load('MaterialIcons', [
    '$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  ]);
}

class _Shot {
  const _Shot(this.name, this.title, this.subtitle, this.setup, {this.dark = false});

  final String name;
  final String title;
  final String subtitle;
  final Future<void> Function(ProviderContainer c) setup;
  final bool dark;
}

// push() completes only when the route is popped, so it must not be awaited.
Future<void> _push(ProviderContainer c, String location) async =>
    unawaited(c.read(routerProvider).push(location));

Future<void> _go(ProviderContainer c, String location) async => c.read(routerProvider).go(location);

void main() {
  setUpAll(() async {
    await _loadFonts();
    // This file is a test (run via `flutter test`) that lives under tool/.
    // ignore: invalid_use_of_visible_for_testing_member
    PackageInfo.setMockInitialValues(
      appName: 'Hisn Al-Muslim',
      packageName: 'com.zaid.hisnalmuslim',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
  });

  // Realistic, non-empty state for the screenshots.
  void seed(ProviderContainer c) {
    final repo = loadContent();
    final progress = c.read(progressProvider.notifier);
    for (final d in repo.itemsOf('morning').take(9)) {
      progress.markComplete(d);
    }
    for (final d in repo.itemsOf('evening')) {
      progress.markComplete(d);
    }
    final fav = c.read(favoritesProvider.notifier);
    for (final id in ['hm79.am', 'hm84.am', 'hm119', 'hm140', 'q2-201', 'hm249']) {
      fav.toggle(id);
    }
    final tasbeeh = c.read(tasbeehProvider.notifier);
    for (var i = 0; i < 54; i++) {
      tasbeeh.increment();
    }
  }

  Future<void> render(WidgetTester tester, {required String lang, required _Shot shot}) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final settings = AppSettings(
      languageCode: lang,
      onboardingDone: true,
      showTranslation: lang == 'en',
      themeMode: shot.dark ? ThemeMode.dark : ThemeMode.light,
    );
    final container = ProviderContainer(
      overrides: [
        keyValueStoreProvider.overrideWithValue(
          MemoryKeyValueStore({SettingsRepository.key: jsonEncode(settings.toJson())}),
        ),
        contentRepositoryProvider.overrideWithValue(loadContent()),
        reminderSchedulerProvider.overrideWithValue(FakeReminderScheduler()),
        clockProvider.overrideWithValue(() => DateTime(2026, 11, 3, 7, 20)),
      ],
    );
    addTearDown(container.dispose);
    seed(container);

    const phone = Size(390, 844);
    await tester.pumpWidget(
      RepaintBoundary(
        key: const ValueKey('frame'),
        child: _StoreFrame(
          title: shot.title,
          subtitle: shot.subtitle,
          rtl: lang == 'ar',
          phone: MediaQuery(
            data: const MediaQueryData(size: phone, padding: EdgeInsets.only(top: 30)),
            child: UncontrolledProviderScope(container: container, child: const HisnApp()),
          ),
          phoneSize: phone,
        ),
      ),
    );
    // Bounded pumps instead of pumpAndSettle so a stray ticker can never hang
    // the render; route transitions and ring animations finish well within.
    Future<void> settle() async {
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    await settle();
    await shot.setup(container);
    await settle();
    await expectLater(
      find.byKey(const ValueKey('frame')),
      matchesGoldenFile('$_out/screenshots/${lang}_${shot.name}.png'),
    );
  }

  final arShots = [
    _Shot('01_home', 'حصّن يومك بذكر الله', 'وِرد يومي، وتذكير هادئ، وتقدّم محفوظ', (c) async {}),
    _Shot(
      '02_reader',
      'قراءة مريحة وعدّاد دقيق',
      'خط عربي واضح مع المصدر والتخريج',
      (c) => _push(c, '/read/morning?start=hm79.am'),
    ),
    _Shot(
      '03_library',
      'مكتبة أذكار كاملة',
      '١٣ قسمًا من حصن المسلم وأدعية من القرآن',
      (c) => _go(c, '/library'),
    ),
    _Shot('04_tasbeeh', 'مسبحة إلكترونية', 'أهداف ودورات وإحصائيات', (c) => _go(c, '/tasbeeh')),
    _Shot(
      '05_category',
      'كل ذكر بعدده ومصدره',
      'تقدّمك محفوظ تلقائيًا كل يوم',
      (c) => _go(c, '/library/morning'),
    ),
    _Shot(
      '06_dark',
      'وضع داكن مريح للعين',
      'واجهة عربية كاملة وأخرى إنجليزية',
      (c) => _push(c, '/read/sleep'),
      dark: true,
    ),
  ];

  final enShots = [
    _Shot(
      '01_home',
      'Fortify your day with dhikr',
      'Daily wird, gentle reminders, saved progress',
      (c) async {},
    ),
    _Shot(
      '02_reader',
      'Calm reading, precise counting',
      'Clear Arabic text with source and translation',
      (c) => _push(c, '/read/morning?start=hm79.am'),
    ),
    _Shot(
      '03_library',
      'A complete adhkar library',
      '13 categories from Hisn al-Muslim and the Quran',
      (c) => _go(c, '/library'),
    ),
    _Shot(
      '04_tasbeeh',
      'Digital tasbeeh',
      'Targets, rounds and statistics',
      (c) => _go(c, '/tasbeeh'),
      dark: true,
    ),
  ];

  for (final shot in arShots) {
    testWidgets('ar ${shot.name}', (t) => render(t, lang: 'ar', shot: shot));
  }
  for (final shot in enShots) {
    testWidgets('en ${shot.name}', (t) => render(t, lang: 'en', shot: shot));
  }

  for (final (lang, title, subtitle) in [
    ('ar', 'حصن المسلم', 'أذكار وأدعية من الكتاب والسنة · تعمل دون إنترنت'),
    ('en', 'Hisn Al-Muslim', 'Authentic daily adhkar & supplications · fully offline'),
  ]) {
    testWidgets('feature graphic $lang', (tester) async {
      tester.view.physicalSize = const Size(1024, 500);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        RepaintBoundary(
          key: const ValueKey('fg'),
          child: _FeatureGraphic(title: title, subtitle: subtitle, rtl: lang == 'ar'),
        ),
      );
      await expectLater(
        find.byKey(const ValueKey('fg')),
        matchesGoldenFile('$_out/feature_graphic/feature_graphic_$lang.png'),
      );
    });
  }
}

class _StoreFrame extends StatelessWidget {
  const _StoreFrame({
    required this.title,
    required this.subtitle,
    required this.rtl,
    required this.phone,
    required this.phoneSize,
  });

  final String title;
  final String subtitle;
  final bool rtl;
  final Widget phone;
  final Size phoneSize;

  @override
  Widget build(BuildContext context) {
    const scale = 1.62;
    return Directionality(
      textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [BrandColors.emerald, BrandColors.emeraldDeep],
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(
              child: IslamicPattern(color: BrandColors.ivory, opacity: 0.07, tile: 110),
            ),
            Positioned(
              top: 70,
              left: 60,
              right: 60,
              child: Column(
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: rtl ? 'Amiri' : 'IBMPlexSansArabic',
                      fontWeight: FontWeight.w700,
                      fontSize: rtl ? 78 : 64,
                      height: 1.35,
                      color: BrandColors.ivory,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 36,
                      height: 1.4,
                      color: BrandColors.gold,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 400,
              left: (1080 - phoneSize.width * scale) / 2,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B201A),
                  borderRadius: BorderRadius.circular(78),
                  boxShadow: const [
                    BoxShadow(color: Color(0x66000000), blurRadius: 60, offset: Offset(0, 30)),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(64),
                  child: SizedBox(
                    width: phoneSize.width * scale,
                    height: phoneSize.height * scale,
                    child: FittedBox(
                      alignment: Alignment.topCenter,
                      child: SizedBox.fromSize(size: phoneSize, child: phone),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureGraphic extends StatelessWidget {
  const _FeatureGraphic({required this.title, required this.subtitle, required this.rtl});

  final String title;
  final String subtitle;
  final bool rtl;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: AlignmentDirectional.centerStart,
            end: AlignmentDirectional.centerEnd,
            colors: [BrandColors.emerald, BrandColors.emeraldDeep],
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(
              child: IslamicPattern(color: BrandColors.ivory, opacity: 0.07, tile: 70),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 72),
              child: Row(
                children: [
                  const BrandMark(size: 260),
                  const SizedBox(width: 48),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontFamily: rtl ? 'Amiri' : 'IBMPlexSansArabic',
                            fontWeight: FontWeight.w700,
                            fontSize: rtl ? 92 : 62,
                            height: 1.3,
                            color: BrandColors.ivory,
                          ),
                        ),
                        const SizedBox(height: 26),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontFamily: 'IBMPlexSansArabic',
                            fontSize: 26,
                            height: 1.5,
                            color: BrandColors.gold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
