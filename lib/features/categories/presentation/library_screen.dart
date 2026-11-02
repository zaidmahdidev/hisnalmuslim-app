import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/gen/app_localizations.dart';
import '../../../app/providers.dart';
import '../../../app/router/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/category_icon.dart';
import '../../../core/widgets/layout.dart';
import '../../../data/models/adhkar_category.dart';
import '../../adhkar/application/progress_controller.dart';

/// All categories as a responsive grid.
class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final categories = ref.watch(contentRepositoryProvider).categories;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.libraryTitle),
        actions: [
          IconButton(
            tooltip: l10n.actionSearch,
            onPressed: () => context.push(Routes.search),
            icon: const Icon(Icons.search_rounded),
          ),
        ],
      ),
      body: ContentWidth(
        maxWidth: 900,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpace.gutter,
                AppSpace.xs,
                AppSpace.gutter,
                AppSpace.md,
              ),
              sliver: SliverToBoxAdapter(child: SearchEntry(label: l10n.searchHint)),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(AppSpace.gutter, 0, AppSpace.gutter, AppSpace.xxl),
              sliver: SliverGrid.builder(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 240,
                  mainAxisSpacing: AppSpace.sm,
                  crossAxisSpacing: AppSpace.sm,
                  mainAxisExtent: CategoryTile.extent(MediaQuery.textScalerOf(context)),
                ),
                itemCount: categories.length,
                itemBuilder: (context, i) => CategoryTile(category: categories[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Grid tile: icon, title, count and today's progress.
class CategoryTile extends ConsumerWidget {
  const CategoryTile({super.key, required this.category});

  final AdhkarCategory category;

  /// Tile height: fixed parts (icon, paddings, gaps, progress bar) plus a
  /// two-line title and a one-line count at the current text scale.
  static double extent(TextScaler scaler) =>
      44 +
      AppSpace.md * 2 +
      AppSpace.md +
      AppSpace.xxs +
      AppSpace.xs +
      4 +
      scaler.scale(14) * 1.45 * 2 +
      scaler.scale(12.5) * 1.55 +
      4;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    final progress = ref.watch(categoryProgressProvider(category.id));

    return AppCard(
      onTap: () => context.push(Routes.category(category.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CategoryIcon(iconKey: category.icon),
              const Spacer(),
              if (progress.isDone) Icon(Icons.verified_rounded, color: p.accent, size: 20),
            ],
          ),
          const Spacer(),
          Text(
            category.title(arabic: arabic),
            style: text.titleSmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpace.xxs),
          Text(
            l10n.libraryItemsCount(progress.total),
            style: text.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpace.xs),
          ClipRRect(
            borderRadius: AppRadius.smAll,
            child: LinearProgressIndicator(
              value: progress.ratio,
              minHeight: 4,
              color: progress.isDone ? p.success : p.accent,
              backgroundColor: p.surfaceSunken,
            ),
          ),
        ],
      ),
    );
  }
}

/// Read-only field that opens the search screen.
class SearchEntry extends StatelessWidget {
  const SearchEntry({super.key, required this.label, this.onHero = false});

  final String label;
  final bool onHero;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final fg = onHero ? p.onHeroMuted : p.textMuted;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: onHero ? p.onHero.withValues(alpha: 0.1) : p.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mdAll,
          side: BorderSide(color: onHero ? p.onHero.withValues(alpha: 0.18) : p.outline),
        ),
        child: InkWell(
          borderRadius: AppRadius.mdAll,
          onTap: () => context.push(Routes.search),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.md, vertical: 14),
            child: Row(
              children: [
                Icon(Icons.search_rounded, color: fg),
                const SizedBox(width: AppSpace.sm),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: fg),
                    overflow: TextOverflow.ellipsis,
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
