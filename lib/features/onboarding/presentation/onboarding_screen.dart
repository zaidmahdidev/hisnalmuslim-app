import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/gen/app_localizations.dart';
import '../../../app/router/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/brand_mark.dart';
import '../../../core/widgets/islamic_pattern.dart';
import '../../../core/widgets/layout.dart';
import '../../../core/widgets/progress_ring.dart';
import '../../../core/widgets/star_badge.dart';
import '../../settings/application/settings_controller.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pages = PageController();
  int _index = 0;

  static const _count = 3;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(settingsProvider.notifier).completeOnboarding();
    if (mounted) context.go(Routes.home);
  }

  void _next() {
    if (_index == _count - 1) {
      _finish();
    } else {
      _pages.nextPage(duration: AppMotion.slow, curve: AppMotion.standard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.palette;
    final settings = ref.watch(settingsProvider);
    final pages = [
      (
        const _Illustration(child: BrandMark(size: 120)),
        l10n.onboardingTitle1,
        l10n.onboardingBody1,
      ),
      (
        _Illustration(
          child: ProgressRing(
            value: 0.66,
            size: 120,
            strokeWidth: 7,
            color: p.accent,
            trackColor: p.onHero.withValues(alpha: 0.2),
            child: Text(
              '٣٣',
              style: TextStyle(fontFamily: AppFonts.reading, fontSize: 40, color: p.onHero),
            ),
          ),
        ),
        l10n.onboardingTitle2,
        l10n.onboardingBody2,
      ),
      (
        _Illustration(
          child: StarBadge(
            size: 120,
            color: p.onHero.withValues(alpha: 0.14),
            outline: p.accent,
            child: Icon(Icons.lock_rounded, color: p.onHero, size: 44),
          ),
        ),
        l10n.onboardingTitle3,
        l10n.onboardingBody3,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: ContentWidth(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpace.md, vertical: AppSpace.xs),
                child: Row(
                  children: [
                    SegmentedButton<String>(
                      showSelectedIcon: false,
                      segments: [
                        ButtonSegment(value: 'ar', label: Text(l10n.languageArabic)),
                        ButtonSegment(value: 'en', label: Text(l10n.languageEnglish)),
                      ],
                      selected: {settings.languageCode},
                      onSelectionChanged: (s) =>
                          ref.read(settingsProvider.notifier).setLanguage(s.first),
                    ),
                    const Spacer(),
                    if (_index < _count - 1)
                      TextButton(onPressed: _finish, child: Text(l10n.actionSkip)),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pages,
                  itemCount: _count,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (context, i) {
                    final (art, title, body) = pages[i];
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpace.xxl),
                      child: Column(
                        children: [
                          const SizedBox(height: AppSpace.xl),
                          art,
                          const SizedBox(height: AppSpace.xxl),
                          Text(
                            title,
                            style: Theme.of(context).textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpace.sm),
                          Text(
                            body,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: p.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpace.xl, 0, AppSpace.xl, AppSpace.lg),
                child: Column(
                  children: [
                    _Dots(count: _count, index: _index),
                    const SizedBox(height: AppSpace.lg),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _next,
                        child: Text(_index == _count - 1 ? l10n.actionStart : l10n.actionNext),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Illustration extends StatelessWidget {
  const _Illustration({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      width: 240,
      height: 240,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [p.hero, p.heroDeep],
        ),
        boxShadow: [
          BoxShadow(
            color: p.shadow.withValues(alpha: 0.18),
            blurRadius: 40,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: ClipOval(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(child: IslamicPattern(color: p.onHero, tile: 48)),
            child,
          ],
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return ExcludeSemantics(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < count; i++)
            AnimatedContainer(
              duration: AppMotion.medium,
              curve: AppMotion.standard,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: i == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: i == index ? p.primary : p.outline,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
        ],
      ),
    );
  }
}
