import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/gen/app_localizations.dart';
import '../../../app/providers.dart';
import '../../../app/router/routes.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../core/widgets/layout.dart';
import '../../../core/widgets/state_views.dart';
import '../../../data/models/adhkar_category.dart';
import '../../adhkar/presentation/widgets/dhikr_preview_card.dart';
import '../application/favorites_controller.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final favorites = ref.watch(favoriteItemsProvider);
    final query = _query.text.trim();
    final visible = query.isEmpty
        ? favorites
        : ref
              .read(contentRepositoryProvider)
              .search(query, onlyIds: {for (final f in favorites) f.id})
              .map((r) => r.dhikr)
              .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.favoritesTitle),
        actions: [
          if (favorites.isNotEmpty)
            TextButton.icon(
              onPressed: () => context.push(Routes.reader(CategoryIds.favorites)),
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(l10n.favoritesReadAll),
            ),
        ],
      ),
      body: favorites.isEmpty
          ? EmptyState(
              icon: Icons.favorite_border_rounded,
              title: l10n.favoritesEmptyTitle,
              message: l10n.favoritesEmptyBody,
              action: OutlinedButton.icon(
                onPressed: () => context.go(Routes.library),
                icon: const Icon(Icons.menu_book_rounded),
                label: Text(l10n.navLibrary),
              ),
            )
          : ContentWidth(
              child: CustomScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpace.gutter,
                      AppSpace.xs,
                      AppSpace.gutter,
                      AppSpace.xs,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: TextField(
                        controller: _query,
                        onChanged: (_) => setState(() {}),
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: l10n.favoritesSearchHint,
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: query.isEmpty
                              ? null
                              : IconButton(
                                  tooltip: l10n.searchClear,
                                  onPressed: () => setState(_query.clear),
                                  icon: const Icon(Icons.close_rounded),
                                ),
                        ),
                      ),
                    ),
                  ),
                  if (visible.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyState(
                        icon: Icons.search_off_rounded,
                        title: l10n.favoritesNoMatch,
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpace.gutter,
                        0,
                        AppSpace.gutter,
                        AppSpace.xxl,
                      ),
                      sliver: SliverList.separated(
                        itemCount: visible.length,
                        separatorBuilder: (_, _) => const SizedBox(height: AppSpace.xs),
                        itemBuilder: (context, i) {
                          final dhikr = visible[i];
                          return DhikrPreviewCard(
                            key: ValueKey(dhikr.id),
                            dhikr: dhikr,
                            showSection: true,
                            onTap: () => context.push(
                              Routes.reader(CategoryIds.favorites, startId: dhikr.id),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
