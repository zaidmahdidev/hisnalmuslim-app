import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/gen/app_localizations.dart';
import '../../../app/providers.dart';
import '../../../app/router/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/brand_mark.dart';
import '../../../core/widgets/category_icon.dart';
import '../../../core/widgets/layout.dart';
import '../../../core/widgets/progress_ring.dart';
import '../../../core/widgets/section_header.dart';
import '../../../data/models/adhkar_category.dart';
import '../../adhkar/application/progress_controller.dart';
import '../../adhkar/presentation/widgets/dhikr_actions.dart';
import '../../adhkar/presentation/widgets/dhikr_text.dart';
import '../application/home_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: _HomeHeader()),
          SliverToBoxAdapter(
            child: ContentWidth(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpace.gutter,
                  AppSpace.xl,
                  AppSpace.gutter,
                  AppSpace.xxl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SectionHeader(title: l10n.homeSuggested),
                    const _SuggestedCard(),
                    const SizedBox(height: AppSpace.xl),
                    SectionHeader(title: l10n.homeQuickAccess),
                    const _QuickAccessGrid(),
                    const SizedBox(height: AppSpace.xl),
                    SectionHeader(title: l10n.homeDailyDhikr),
                    const _DailyDhikrCard(),
                    const SizedBox(height: AppSpace.xl),
                    SectionHeader(
                      title: l10n.homeAllCategories,
                      actionLabel: l10n.actionSeeAll,
                      onAction: () => context.go(Routes.library),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: _AllCategoriesStrip()),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpace.xxl)),
        ],
      ),
    );
  }
}

class _HomeHeader extends ConsumerWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    final period = ref.watch(dayPartProvider);
    final greeting = switch (period) {
      DayPart.morning => l10n.greetingMorning,
      DayPart.day => l10n.greetingDay,
      DayPart.evening => l10n.greetingEvening,
      DayPart.night => l10n.greetingNight,
    };

    return HeroSurface(
      child: SafeArea(
        bottom: false,
        child: ContentWidth(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpace.gutter,
              AppSpace.sm,
              AppSpace.xs,
              AppSpace.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const BrandMark(size: 40),
                    const SizedBox(width: AppSpace.sm),
                    Expanded(
                      child: Text(
                        l10n.appName,
                        style: TextStyle(
                          fontFamily: AppFonts.reading,
                          fontWeight: FontWeight.w700,
                          fontSize: 24,
                          height: 1.4,
                          color: p.onHero,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.actionSearch,
                      color: p.onHero,
                      onPressed: () => context.push(Routes.search),
                      icon: const Icon(Icons.search_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpace.lg),
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: AppSpace.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(greeting, style: text.headlineSmall?.copyWith(color: p.onHero)),
                      const SizedBox(height: AppSpace.xxs),
                      Text(l10n.appTagline, style: text.bodyMedium?.copyWith(color: p.onHeroMuted)),
                      const SizedBox(height: AppSpace.lg),
                      const _WirdCard(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WirdCard extends ConsumerWidget {
  const _WirdCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    final morning = ref.watch(categoryProgressProvider(CategoryIds.morning));
    final evening = ref.watch(categoryProgressProvider(CategoryIds.evening));
    final streak = ref.watch(streakProvider);
    final done = morning.completed + evening.completed;
    final total = morning.total + evening.total;

    return Container(
      padding: const EdgeInsets.all(AppSpace.md),
      decoration: BoxDecoration(
        color: p.onHero.withValues(alpha: 0.08),
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: p.onHero.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: [
          ProgressRing(
            value: total == 0 ? 0 : done / total,
            color: p.accent,
            trackColor: p.onHero.withValues(alpha: 0.15),
            size: 64,
            strokeWidth: 6,
            child: Text(
              '${total == 0 ? 0 : (done * 100 / total).round()}%',
              style: text.labelMedium?.copyWith(color: p.onHero),
            ),
          ),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.homeTodayWird, style: text.titleSmall?.copyWith(color: p.onHero)),
                const SizedBox(height: AppSpace.xxs),
                _WirdLine(
                  label: l10n.reminderMorning,
                  progress: morning,
                  onTap: () => context.push(Routes.reader(CategoryIds.morning)),
                ),
                _WirdLine(
                  label: l10n.reminderEvening,
                  progress: evening,
                  onTap: () => context.push(Routes.reader(CategoryIds.evening)),
                ),
                const SizedBox(height: AppSpace.xxs),
                Row(
                  children: [
                    Icon(Icons.local_fire_department_rounded, size: 16, color: p.accent),
                    const SizedBox(width: AppSpace.xxs),
                    Flexible(
                      child: Text(
                        l10n.homeStreak(streak),
                        style: text.labelSmall?.copyWith(color: p.onHeroMuted),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WirdLine extends StatelessWidget {
  const _WirdLine({required this.label, required this.progress, required this.onTap});

  final String label;
  final CategoryProgress progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.smAll,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Icon(
              progress.isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              size: 16,
              color: progress.isDone ? p.accent : p.onHeroMuted,
            ),
            const SizedBox(width: AppSpace.xs),
            Expanded(
              child: Text(label, style: text.bodySmall?.copyWith(color: p.onHero)),
            ),
            Text(
              l10n.homeWirdProgress(progress.completed, progress.total),
              style: text.labelSmall?.copyWith(color: p.onHeroMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestedCard extends ConsumerWidget {
  const _SuggestedCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    final categoryId = ref.watch(suggestedCategoryProvider);
    final category = ref.watch(contentRepositoryProvider).category(categoryId);
    if (category == null) return const SizedBox.shrink();
    final progress = ref.watch(categoryProgressProvider(categoryId));

    return AppCard(
      onTap: () => context.push(Routes.reader(categoryId)),
      child: Row(
        children: [
          CategoryIcon(iconKey: category.icon, size: 56),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category.title(arabic: arabic), style: text.titleMedium),
                const SizedBox(height: 2),
                Text(
                  progress.isDone ? l10n.homeCompletedToday : category.subtitle(arabic: arabic),
                  style: text.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpace.xs),
                ClipRRect(
                  borderRadius: AppRadius.smAll,
                  child: LinearProgressIndicator(
                    value: progress.ratio,
                    minHeight: 5,
                    color: progress.isDone ? p.success : p.accent,
                    backgroundColor: p.surfaceSunken,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpace.sm),
          DecoratedBox(
            decoration: BoxDecoration(color: p.primary, shape: BoxShape.circle),
            child: Padding(
              padding: const EdgeInsets.all(AppSpace.sm),
              child: Icon(
                progress.isDone ? Icons.replay_rounded : Icons.play_arrow_rounded,
                color: p.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAccessGrid extends ConsumerWidget {
  const _QuickAccessGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    final repo = ref.watch(contentRepositoryProvider);

    _Shortcut forCategory(String id) {
      final c = repo.category(id);
      return _Shortcut(
        icon: c?.icon ?? id,
        label: c?.title(arabic: arabic) ?? id,
        onTap: () => context.push(Routes.reader(id)),
      );
    }

    final shortcuts = [
      forCategory(CategoryIds.morning),
      forCategory(CategoryIds.evening),
      forCategory(CategoryIds.sleep),
      forCategory(CategoryIds.afterPrayer),
      _Shortcut(icon: 'tasbeeh', label: l10n.navTasbeeh, onTap: () => context.go(Routes.tasbeeh)),
      _Shortcut(
        icon: 'favorites',
        label: l10n.navFavorites,
        onTap: () => context.go(Routes.favorites),
      ),
    ];

    // Height follows the text scale so two-line labels never overflow.
    final labelHeight = MediaQuery.textScalerOf(context).scale(13) * 1.35 * 2;
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: AppSpace.sm,
        crossAxisSpacing: AppSpace.sm,
        mainAxisExtent: 44 + AppSpace.xs * 3 + labelHeight + 6,
      ),
      children: [for (final s in shortcuts) _ShortcutTile(shortcut: s)],
    );
  }
}

class _Shortcut {
  const _Shortcut({required this.icon, required this.label, required this.onTap});

  final String icon;
  final String label;
  final VoidCallback onTap;
}

class _ShortcutTile extends StatelessWidget {
  const _ShortcutTile({required this.shortcut});

  final _Shortcut shortcut;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AppCard(
      onTap: shortcut.onTap,
      padding: const EdgeInsets.all(AppSpace.xs),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (shortcut.icon == 'tasbeeh')
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: p.primarySoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.radio_button_checked_rounded, color: p.primary, size: 23),
            )
          else
            CategoryIcon(iconKey: shortcut.icon),
          const SizedBox(height: AppSpace.xs),
          Text(
            shortcut.label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(color: p.textPrimary),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _DailyDhikrCard extends ConsumerWidget {
  const _DailyDhikrCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final p = context.palette;
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    final dhikr = ref.watch(dailyDhikrProvider);
    if (dhikr == null) return const SizedBox.shrink();
    final text = Theme.of(context).textTheme;

    return AppCard(
      onTap: () => context.push(Routes.reader(dhikr.categoryId, startId: dhikr.id)),
      padding: const EdgeInsets.fromLTRB(AppSpace.lg, AppSpace.md, AppSpace.lg, AppSpace.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            dhikr.section(arabic: arabic),
            style: text.labelMedium?.copyWith(color: p.accent),
          ),
          const SizedBox(height: AppSpace.sm),
          DhikrText(dhikr: dhikr, size: 22),
          const SizedBox(height: AppSpace.xs),
          Row(
            children: [
              if (dhikr.refs.isNotEmpty)
                Expanded(
                  child: Text(
                    dhikr.refs.map((r) => r.label(arabic: arabic)).join(' · '),
                    style: text.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              else
                const Spacer(),
              IconButton(
                tooltip: l10n.actionCopy,
                onPressed: () => DhikrActions.copy(context, ref, dhikr),
                icon: const Icon(Icons.copy_rounded, size: 20),
              ),
              Builder(
                builder: (context) => IconButton(
                  tooltip: l10n.actionShare,
                  onPressed: () => DhikrActions.share(context, dhikr),
                  icon: const Icon(Icons.ios_share_rounded, size: 20),
                ),
              ),
              FavoriteButton(dhikr: dhikr),
            ],
          ),
        ],
      ),
    );
  }
}

class _AllCategoriesStrip extends ConsumerWidget {
  const _AllCategoriesStrip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    final categories = ref.watch(contentRepositoryProvider).categories;
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.gutter),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpace.xs),
        itemBuilder: (context, i) {
          final c = categories[i];
          return ActionChip(
            avatar: Icon(CategoryIcons.of(c.icon), size: 18, color: context.palette.primary),
            label: Text(c.title(arabic: arabic)),
            onPressed: () => context.push(Routes.category(c.id)),
          );
        },
      ),
    );
  }
}
