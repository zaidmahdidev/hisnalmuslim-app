import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/localization/gen/app_localizations.dart';
import '../../../app/providers.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/category_icon.dart';
import '../../../core/widgets/layout.dart';
import '../../../core/widgets/star_badge.dart';
import '../../../core/widgets/state_views.dart';
import '../../../data/models/adhkar_category.dart';
import '../../../data/models/app_settings.dart';
import '../../../data/models/dhikr.dart';
import '../../settings/application/settings_controller.dart';
import '../application/progress_controller.dart';
import 'widgets/counter_button.dart';
import 'widgets/dhikr_actions.dart';
import 'widgets/dhikr_text.dart';
import 'widgets/reference_sheet.dart';

/// Distraction-free reading of a category (or the favorites) one dhikr at a
/// time, with a repetition counter and persisted progress.
class ReaderScreen extends ConsumerStatefulWidget {
  const ReaderScreen({super.key, required this.categoryId, this.startId});

  final String categoryId;

  /// Optional dhikr id to open at (from search, favorites or home).
  final String? startId;

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  late final List<Dhikr> _items;
  late final PageController _pages;
  late int _index;
  Timer? _advanceTimer;
  bool _completionShown = false;

  @override
  void initState() {
    super.initState();
    // Snapshot the list so pages stay stable even if favorites change.
    _items = List.of(ref.read(readingListProvider(widget.categoryId)));
    _index = _initialIndex();
    _pages = PageController(initialPage: _index);
    _completionShown = ref.read(categoryProgressProvider(widget.categoryId)).isDone;
  }

  int _initialIndex() {
    if (_items.isEmpty) return 0;
    if (widget.startId != null) {
      final i = _items.indexWhere((d) => d.id == widget.startId);
      if (i >= 0) return i;
    }
    final progress = ref.read(progressProvider);
    final saved = progress.positions[widget.categoryId];
    if (saved != null && saved < _items.length) return saved;
    final firstOpen = _items.indexWhere((d) => progress.countOf(d.id) < d.repeat);
    return firstOpen < 0 ? 0 : firstOpen;
  }

  @override
  void dispose() {
    _advanceTimer?.cancel();
    _pages.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    if (index < 0 || index >= _items.length) return;
    _pages.animateToPage(index, duration: AppMotion.slow, curve: AppMotion.standard);
  }

  void _count(Dhikr dhikr) {
    _advanceTimer?.cancel();
    final progress = ref.read(progressProvider.notifier);
    final before = ref.read(progressProvider).countOf(dhikr.id);
    if (before >= dhikr.repeat) {
      _goTo(_index + 1);
      return;
    }
    final after = progress.increment(dhikr);
    final feedback = ref.read(feedbackProvider);
    if (after >= dhikr.repeat) {
      unawaited(feedback.success());
      _onCompleted();
    } else {
      unawaited(feedback.tick());
    }
  }

  void _onCompleted() {
    if (_allDone && !_completionShown) {
      _completionShown = true;
      _advanceTimer = Timer(const Duration(milliseconds: 500), _showCompletion);
      return;
    }
    final settings = ref.read(settingsProvider);
    final current = _index;
    if (settings.autoAdvance && current < _items.length - 1) {
      _advanceTimer = Timer(const Duration(milliseconds: 450), () {
        if (mounted && _index == current) _goTo(current + 1);
      });
    }
  }

  bool get _allDone {
    final progress = ref.read(progressProvider);
    return _items.every((d) => progress.countOf(d.id) >= d.repeat);
  }

  String _title(AppLocalizations l10n, bool arabic) {
    if (widget.categoryId == CategoryIds.favorites) return l10n.favoritesTitle;
    return ref.read(contentRepositoryProvider).category(widget.categoryId)?.title(arabic: arabic) ??
        l10n.appName;
  }

  Future<void> _showCompletion() async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    final leave = await showModalBottomSheet<bool>(
      context: context,
      builder: (context) => _CompletionSheet(title: l10n.readerCompleteTitle(_title(l10n, arabic))),
    );
    if (leave == true && mounted) Navigator.of(context).maybePop();
  }

  Future<void> _showOptions(Dhikr dhikr) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _DisplayOptionsSheet(dhikr: dhikr),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    final title = _title(l10n, arabic);

    if (_items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: EmptyState(icon: Icons.menu_book_rounded, title: l10n.readerEmpty),
      );
    }

    final settings = ref.watch(settingsProvider);
    final progress = ref.watch(progressProvider);
    final dhikr = _items[_index];
    final completed = _items.where((d) => progress.countOf(d.id) >= d.repeat).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          FavoriteButton(dhikr: dhikr),
          IconButton(
            tooltip: l10n.readerDisplayOptions,
            onPressed: () => _showOptions(dhikr),
            icon: const Icon(Icons.text_fields_rounded),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(28),
          child: _ReaderProgress(completed: completed, total: _items.length, index: _index),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pages,
              itemCount: _items.length,
              onPageChanged: (i) {
                _advanceTimer?.cancel();
                setState(() => _index = i);
                if (widget.categoryId != CategoryIds.favorites) {
                  ref.read(progressProvider.notifier).setPosition(widget.categoryId, i);
                }
              },
              itemBuilder: (context, i) => _ReaderPage(
                dhikr: _items[i],
                settings: settings,
                onTapText: settings.tapTextToCount ? () => _count(_items[i]) : null,
              ),
            ),
          ),
          _ReaderControls(
            dhikr: dhikr,
            count: progress.countOf(dhikr.id),
            isFirst: _index == 0,
            isLast: _index == _items.length - 1,
            onCount: () => _count(dhikr),
            onPrevious: () => _goTo(_index - 1),
            onNext: () => _goTo(_index + 1),
          ),
        ],
      ),
    );
  }
}

class _ReaderProgress extends StatelessWidget {
  const _ReaderProgress({required this.completed, required this.total, required this.index});

  final int completed;
  final int total;
  final int index;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpace.gutter, 0, AppSpace.gutter, AppSpace.xs),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: AppRadius.smAll,
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: total == 0 ? 0 : completed / total),
                duration: AppMotion.slow,
                curve: AppMotion.standard,
                builder: (_, v, _) => LinearProgressIndicator(
                  value: v,
                  minHeight: 5,
                  color: p.accent,
                  backgroundColor: p.surfaceSunken,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpace.sm),
          Text(
            l10n.readerOf(index + 1, total),
            style: Theme.of(context).textTheme.labelMedium
                ?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
          ),
        ],
      ),
    );
  }
}

class _ReaderPage extends StatelessWidget {
  const _ReaderPage({required this.dhikr, required this.settings, this.onTapText});

  final Dhikr dhikr;
  final AppSettings settings;
  final VoidCallback? onTapText;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    final showTranslation = settings.showTranslation && dhikr.translation.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.gutter,
        AppSpace.md,
        AppSpace.gutter,
        AppSpace.xl,
      ),
      child: ContentWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Pill(
                  label: dhikr.isQuran ? l10n.readerQuran : l10n.readerSunnah,
                  icon: dhikr.isQuran ? Icons.menu_book_rounded : Icons.auto_awesome_rounded,
                  color: dhikr.isQuran ? p.primarySoft : p.accentSoft,
                  textColor: dhikr.isQuran ? p.primary : p.accent,
                ),
                const SizedBox(width: AppSpace.xs),
                Expanded(
                  child: Text(
                    dhikr.section(arabic: arabic),
                    style: text.labelMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (dhikr.repeat > 1) Pill(label: l10n.repeatCount(dhikr.repeat)),
              ],
            ),
            const SizedBox(height: AppSpace.md),
            AppCard(
              onTap: onTapText,
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg, vertical: AppSpace.xl),
              child: DhikrText(dhikr: dhikr, scale: settings.readingScale),
            ),
            if (showTranslation) ...[
              const SizedBox(height: AppSpace.md),
              _TranslationCard(dhikr: dhikr),
            ],
            const SizedBox(height: AppSpace.md),
            _ReferenceRow(dhikr: dhikr),
          ],
        ),
      ),
    );
  }
}

class _TranslationCard extends StatelessWidget {
  const _TranslationCard({required this.dhikr});

  final Dhikr dhikr;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        padding: const EdgeInsets.all(AppSpace.md),
        decoration: BoxDecoration(color: p.surfaceSunken, borderRadius: AppRadius.mdAll),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dhikr.translation, style: text.bodyLarge?.copyWith(height: 1.65)),
            if (dhikr.translationSource.isNotEmpty) ...[
              const SizedBox(height: AppSpace.xs),
              Text(l10n.readerTranslationBy(dhikr.translationSource), style: text.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReferenceRow extends StatelessWidget {
  const _ReferenceRow({required this.dhikr});

  final Dhikr dhikr;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.palette;
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    return AppCard(
      elevated: false,
      color: p.background,
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.md, vertical: AppSpace.sm),
      onTap: () => ReferenceSheet.show(context, dhikr),
      child: Row(
        children: [
          Icon(Icons.bookmark_rounded, size: 20, color: p.accent),
          const SizedBox(width: AppSpace.sm),
          Expanded(
            child: dhikr.refs.isEmpty
                ? Text(
                    dhikr.footnote.isEmpty ? l10n.readerReferenceMissing : l10n.readerReference,
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                : Wrap(
                    spacing: AppSpace.xs,
                    runSpacing: AppSpace.xxs,
                    children: [for (final r in dhikr.refs) Pill(label: r.label(arabic: arabic))],
                  ),
          ),
          Icon(Icons.chevron_right_rounded, color: p.textMuted),
        ],
      ),
    );
  }
}

class _ReaderControls extends StatelessWidget {
  const _ReaderControls({
    required this.dhikr,
    required this.count,
    required this.isFirst,
    required this.isLast,
    required this.onCount,
    required this.onPrevious,
    required this.onNext,
  });

  final Dhikr dhikr;
  final int count;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onCount;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.palette;
    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        border: Border(top: BorderSide(color: p.outline)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.md, vertical: AppSpace.sm),
          child: ContentWidth(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Consumer(
                  builder: (context, ref, _) => IconButton(
                    tooltip: l10n.actionCopy,
                    onPressed: () => DhikrActions.copy(context, ref, dhikr),
                    icon: const Icon(Icons.copy_rounded),
                  ),
                ),
                IconButton.filledTonal(
                  style: IconButton.styleFrom(
                    backgroundColor: p.primarySoft,
                    foregroundColor: p.primary,
                    disabledBackgroundColor: p.surfaceSunken,
                  ),
                  tooltip: l10n.actionPrevious,
                  onPressed: isFirst ? null : onPrevious,
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                CounterButton(count: count, total: dhikr.repeat, onTap: onCount),
                IconButton.filledTonal(
                  style: IconButton.styleFrom(
                    backgroundColor: p.primarySoft,
                    foregroundColor: p.primary,
                    disabledBackgroundColor: p.surfaceSunken,
                  ),
                  tooltip: l10n.actionNext,
                  onPressed: isLast ? null : onNext,
                  icon: const Icon(Icons.arrow_forward_rounded),
                ),
                Builder(
                  builder: (context) => IconButton(
                    tooltip: l10n.actionShare,
                    onPressed: () => DhikrActions.share(context, dhikr),
                    icon: const Icon(Icons.ios_share_rounded),
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

class _DisplayOptionsSheet extends ConsumerWidget {
  const _DisplayOptionsSheet({required this.dhikr});

  final Dhikr dhikr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);
    final text = Theme.of(context).textTheme;
    final p = context.palette;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(AppSpace.xl, 0, AppSpace.xl, AppSpace.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.readerDisplayOptions, style: text.titleLarge),
            const SizedBox(height: AppSpace.md),
            Container(
              padding: const EdgeInsets.all(AppSpace.md),
              decoration: BoxDecoration(color: p.surfaceSunken, borderRadius: AppRadius.mdAll),
              child: DhikrText(dhikr: dhikr, scale: settings.readingScale, maxLines: 2),
            ),
            const SizedBox(height: AppSpace.sm),
            Text(l10n.readerFontSize, style: text.titleSmall),
            Row(
              children: [
                Icon(Icons.text_decrease_rounded, color: p.textMuted),
                Expanded(
                  child: Slider(
                    value: settings.readingScale,
                    min: AppSettings.minReadingScale,
                    max: AppSettings.maxReadingScale,
                    divisions: 10,
                    label: '${(settings.readingScale * 100).round()}%',
                    onChanged: controller.setReadingScale,
                  ),
                ),
                Icon(Icons.text_increase_rounded, color: p.textMuted),
              ],
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.readerShowTranslation),
              value: settings.showTranslation,
              onChanged: controller.setShowTranslation,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.readerAutoAdvance),
              value: settings.autoAdvance,
              onChanged: controller.setAutoAdvance,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.readerTapText),
              value: settings.tapTextToCount,
              onChanged: controller.setTapTextToCount,
            ),
            const SizedBox(height: AppSpace.sm),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ref.read(progressProvider.notifier).resetItem(dhikr);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.restart_alt_rounded),
                    label: Text(l10n.readerResetCount),
                  ),
                ),
                const SizedBox(width: AppSpace.sm),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      ref.read(progressProvider.notifier).markComplete(dhikr);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.done_all_rounded),
                    label: Text(l10n.readerMarkDone),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletionSheet extends StatelessWidget {
  const _CompletionSheet({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpace.xl, 0, AppSpace.xl, AppSpace.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.6, end: 1),
              duration: AppMotion.slow,
              curve: AppMotion.emphasized,
              builder: (_, v, child) => Transform.scale(scale: v, child: child),
              child: StarBadge(
                color: p.primary,
                outline: p.accent,
                child: Icon(Icons.check_rounded, color: p.onPrimary, size: 40),
              ),
            ),
            const SizedBox(height: AppSpace.md),
            Text(title, style: text.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: AppSpace.xs),
            Text(l10n.readerCompleteBody, style: text.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: AppSpace.xl),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
              child: Text(l10n.readerBackToList),
            ),
            const SizedBox(height: AppSpace.xs),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.readerStay),
            ),
          ],
        ),
      ),
    );
  }
}
