import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/gen/app_localizations.dart';
import '../../../app/providers.dart';
import '../../../app/router/routes.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../core/widgets/layout.dart';
import '../../../core/widgets/state_views.dart';
import '../../../data/repositories/content_repository.dart';
import '../../adhkar/presentation/widgets/dhikr_preview_card.dart';

/// Offline search across all adhkar with Arabic normalisation.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  String _query = '';
  List<SearchResult> _results = const [];

  static const _suggestionsAr = [
    'الصباح',
    'النوم',
    'السفر',
    'الكرب',
    'الاستغفار',
    'المطر',
    'الطعام',
  ];
  static const _suggestionsEn = [
    'morning',
    'sleep',
    'travel',
    'anguish',
    'forgiveness',
    'rain',
    'eating',
  ];

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 180), () => _run(value));
  }

  void _run(String value) {
    if (!mounted) return;
    final query = value.trim();
    setState(() {
      _query = query;
      _results = query.isEmpty ? const [] : ref.read(contentRepositoryProvider).search(query);
    });
  }

  void _useSuggestion(String s) {
    _controller.text = s;
    _controller.selection = TextSelection.collapsed(offset: s.length);
    _run(s);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsetsDirectional.only(end: AppSpace.md),
          child: TextField(
            controller: _controller,
            autofocus: true,
            onChanged: _onChanged,
            onSubmitted: _run,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: l10n.searchHint,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _controller.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: l10n.searchClear,
                      onPressed: () {
                        _controller.clear();
                        _run('');
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
            ),
          ),
        ),
      ),
      body: ContentWidth(
        child: _query.isEmpty
            ? ListView(
                padding: const EdgeInsets.all(AppSpace.gutter),
                children: [
                  Text(l10n.searchIntro, style: text.bodyMedium),
                  const SizedBox(height: AppSpace.lg),
                  Text(l10n.searchSuggestions, style: text.titleSmall),
                  const SizedBox(height: AppSpace.xs),
                  Wrap(
                    spacing: AppSpace.xs,
                    runSpacing: AppSpace.xs,
                    children: [
                      for (final s in arabic ? _suggestionsAr : _suggestionsEn)
                        ActionChip(label: Text(s), onPressed: () => _useSuggestion(s)),
                    ],
                  ),
                ],
              )
            : _results.isEmpty
            ? EmptyState(
                icon: Icons.search_off_rounded,
                title: l10n.searchNoResults(_query),
                message: l10n.searchNoResultsHint,
              )
            : ListView.separated(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(
                  AppSpace.gutter,
                  AppSpace.xs,
                  AppSpace.gutter,
                  AppSpace.xxl,
                ),
                itemCount: _results.length + 1,
                separatorBuilder: (_, _) => const SizedBox(height: AppSpace.xs),
                itemBuilder: (context, i) {
                  if (i == 0) {
                    return Semantics(
                      liveRegion: true,
                      child: Text(
                        l10n.searchResultsCount(_results.length),
                        style: text.labelMedium,
                      ),
                    );
                  }
                  final dhikr = _results[i - 1].dhikr;
                  return DhikrPreviewCard(
                    key: ValueKey(dhikr.id),
                    dhikr: dhikr,
                    showSection: true,
                    onTap: () => context.push(Routes.reader(dhikr.categoryId, startId: dhikr.id)),
                  );
                },
              ),
      ),
    );
  }
}
