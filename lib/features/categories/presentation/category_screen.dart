import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/gen/app_localizations.dart';
import '../../../app/providers.dart';
import '../../../app/router/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../core/widgets/category_icon.dart';
import '../../../core/widgets/layout.dart';
import '../../../core/widgets/progress_ring.dart';
import '../../../core/widgets/state_views.dart';
import '../../adhkar/application/progress_controller.dart';
import '../../adhkar/presentation/widgets/dhikr_preview_card.dart';

/// Overview of one category: header with today's progress and a resume
/// button, then every dhikr grouped by the book's chapter headings.
class CategoryScreen extends ConsumerWidget {
  const CategoryScreen({super.key, required this.categoryId});

  final String categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final repo = ref.watch(contentRepositoryProvider);
    final category = repo.category(categoryId);
    if (category == null) {
      return Scaffold(
        appBar: AppBar(),
        body: EmptyState(icon: Icons.search_off_rounded, title: l10n.notFoundTitle),
      );
    }
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    final sections = repo.sectionsOf(categoryId);
    final progress = ref.watch(categoryProgressProvider(categoryId));
    final p = context.palette;
    final text = Theme.of(context).textTheme;

    void open([String? id]) => context.push(Routes.reader(categoryId, startId: id));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: p.hero,
            foregroundColor: p.onHero,
            title: Text(category.title(arabic: arabic)),
            titleTextStyle: text.titleLarge?.copyWith(color: p.onHero),
          ),
          SliverToBoxAdapter(
            child: HeroSurface(
              child: SafeArea(
                top: false,
                bottom: false,
                child: ContentWidth(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpace.gutter,
                      AppSpace.xs,
                      AppSpace.gutter,
                      AppSpace.xl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CategoryIcon(iconKey: category.icon, size: 52, inverted: true),
                            const SizedBox(width: AppSpace.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    category.subtitle(arabic: arabic),
                                    style: text.bodyMedium?.copyWith(color: p.onHeroMuted),
                                  ),
                                  const SizedBox(height: AppSpace.xxs),
                                  Text(
                                    l10n.libraryItemsCount(progress.total),
                                    style: text.labelMedium?.copyWith(color: p.onHero),
                                  ),
                                ],
                              ),
                            ),
                            ProgressRing(
                              value: progress.ratio,
                              color: p.accent,
                              trackColor: p.onHero.withValues(alpha: 0.15),
                              child: Text(
                                '${progress.completed}/${progress.total}',
                                style: text.labelSmall?.copyWith(color: p.onHero),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpace.lg),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: p.onHero,
                              foregroundColor: p.hero,
                            ),
                            onPressed: open,
                            icon: Icon(
                              progress.isDone
                                  ? Icons.replay_rounded
                                  : (progress.isStarted
                                        ? Icons.play_arrow_rounded
                                        : Icons.menu_book_rounded),
                            ),
                            label: Text(
                              progress.isDone
                                  ? l10n.categoryReadAgain
                                  : (progress.isStarted
                                        ? l10n.categoryContinue
                                        : l10n.categoryStart),
                            ),
                          ),
                        ),
                        if (progress.isDone) ...[
                          const SizedBox(height: AppSpace.sm),
                          Row(
                            children: [
                              Icon(Icons.verified_rounded, size: 18, color: p.accent),
                              const SizedBox(width: AppSpace.xs),
                              Text(
                                l10n.categoryDoneToday,
                                style: text.labelMedium?.copyWith(color: p.onHero),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          for (final section in sections) ...[
            if (sections.length > 1)
              SliverToBoxAdapter(
                child: ContentWidth(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpace.gutter,
                      AppSpace.xl,
                      AppSpace.gutter,
                      AppSpace.xs,
                    ),
                    child: Semantics(
                      header: true,
                      child: Text(section.title(arabic: arabic), style: text.titleSmall),
                    ),
                  ),
                ),
              )
            else
              const SliverToBoxAdapter(child: SizedBox(height: AppSpace.md)),
            SliverList.builder(
              itemCount: section.items.length,
              itemBuilder: (context, i) {
                final dhikr = section.items[i];
                return ContentWidth(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpace.gutter,
                      AppSpace.xs,
                      AppSpace.gutter,
                      0,
                    ),
                    child: DhikrPreviewCard(
                      dhikr: dhikr,
                      index: dhikr.order + 1,
                      onTap: () => open(dhikr.id),
                      key: ValueKey(dhikr.id),
                    ),
                  ),
                );
              },
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: AppSpace.xxxl)),
        ],
      ),
    );
  }
}
