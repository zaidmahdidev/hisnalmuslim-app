import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/localization/gen/app_localizations.dart';
import '../../../app/providers.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/islamic_pattern.dart';
import '../../../core/widgets/layout.dart';
import '../../../core/widgets/progress_ring.dart';
import '../../settings/application/settings_controller.dart';
import '../application/tasbeeh_controller.dart';
import '../domain/tasbeeh_presets.dart';

class TasbeehScreen extends ConsumerWidget {
  const TasbeehScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final settingsCtrl = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tasbeehTitle),
        actions: [
          IconButton(
            tooltip: l10n.tasbeehSound,
            isSelected: settings.soundEnabled,
            onPressed: () => settingsCtrl.setSound(!settings.soundEnabled),
            icon: const Icon(Icons.volume_off_rounded),
            selectedIcon: const Icon(Icons.volume_up_rounded),
          ),
          IconButton(
            tooltip: l10n.tasbeehHaptics,
            isSelected: settings.hapticsEnabled,
            onPressed: () => settingsCtrl.setHaptics(!settings.hapticsEnabled),
            icon: const Icon(Icons.mobile_off_rounded),
            selectedIcon: const Icon(Icons.vibration_rounded),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ContentWidth(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final ring = math.min(constraints.maxWidth * 0.74, constraints.maxHeight * 0.46);
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpace.gutter,
                  AppSpace.xs,
                  AppSpace.gutter,
                  AppSpace.xl,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight - AppSpace.xl * 2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const _DhikrSelector(),
                      const SizedBox(height: AppSpace.lg),
                      _CounterDial(size: math.max(ring, 220)),
                      const SizedBox(height: AppSpace.lg),
                      const _TargetSelector(),
                      const SizedBox(height: AppSpace.md),
                      const _StatsRow(),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DhikrSelector extends ConsumerWidget {
  const _DhikrSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final p = context.palette;
    final dhikr = ref.watch(selectedTasbeehProvider);
    final arabic = Localizations.localeOf(context).languageCode == 'ar';

    return AppCard(
      onTap: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => const _DhikrPickerSheet(),
      ),
      semanticLabel: '${l10n.tasbeehChoose}: ${dhikr.text}',
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.md, vertical: AppSpace.sm),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    dhikr.text,
                    textAlign: TextAlign.center,
                    style: AppTypography.reading(p, size: 26).copyWith(height: 1.7),
                  ),
                ),
                if (!arabic && dhikr.meaningEn.isNotEmpty)
                  Text(dhikr.meaningEn, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Icon(Icons.unfold_more_rounded, color: p.textMuted),
        ],
      ),
    );
  }
}

class _CounterDial extends ConsumerStatefulWidget {
  const _CounterDial({required this.size});

  final double size;

  @override
  ConsumerState<_CounterDial> createState() => _CounterDialState();
}

class _CounterDialState extends ConsumerState<_CounterDial> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  );
  bool _pressed = false;

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  void _tap() {
    final tick = ref.read(tasbeehProvider.notifier).increment();
    final feedback = ref.read(feedbackProvider);
    if (tick == TasbeehTick.roundCompleted) {
      unawaited(feedback.success());
      _pulse.forward(from: 0);
      final l10n = AppLocalizations.of(context);
      unawaited(
        SemanticsService.sendAnnouncement(
          View.of(context),
          l10n.tasbeehRoundDone,
          Directionality.of(context),
        ),
      );
    } else {
      unawaited(feedback.tick());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    final state = ref.watch(tasbeehProvider);
    final size = widget.size;

    return Column(
      children: [
        Semantics(
          button: true,
          label: l10n.tasbeehCountSemantics(state.count),
          hint: l10n.tasbeehTapHint,
          excludeSemantics: true,
          onTap: _tap,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (_) => setState(() => _pressed = true),
            onTapUp: (_) => setState(() => _pressed = false),
            onTapCancel: () => setState(() => _pressed = false),
            onTap: _tap,
            child: AnimatedScale(
              scale: _pressed ? 0.965 : 1,
              duration: AppMotion.fast,
              child: SizedBox.square(
                dimension: size,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Round-complete pulse.
                    AnimatedBuilder(
                      animation: _pulse,
                      builder: (_, _) => Opacity(
                        opacity: (1 - _pulse.value) * (_pulse.isAnimating ? 0.5 : 0),
                        child: Container(
                          width: size * (0.9 + 0.12 * _pulse.value),
                          height: size * (0.9 + 0.12 * _pulse.value),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: p.accent, width: 3),
                          ),
                        ),
                      ),
                    ),
                    ProgressRing(
                      size: size,
                      strokeWidth: 8,
                      value: state.unlimited ? 0 : state.progress,
                      color: p.accent,
                      trackColor: p.outline,
                    ),
                    Container(
                      width: size - 34,
                      height: size - 34,
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
                            blurRadius: 30,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned.fill(
                              child: IslamicPattern(color: p.onHero, opacity: 0.06, tile: 44),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${state.count}',
                                  style: text.displaySmall?.copyWith(
                                    color: p.onHero,
                                    fontSize: size * 0.24,
                                    fontWeight: FontWeight.w600,
                                    height: 1.1,
                                    fontFeatures: const [FontFeature.tabularFigures()],
                                  ),
                                ),
                                Text(
                                  state.unlimited ? '∞' : '/ ${state.target}',
                                  textDirection: TextDirection.ltr,
                                  style: text.titleMedium?.copyWith(color: p.onHeroMuted),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpace.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(l10n.tasbeehTapHint, style: text.bodySmall, textAlign: TextAlign.center),
            ),
            const SizedBox(width: AppSpace.sm),
            IconButton.outlined(
              tooltip: l10n.actionReset,
              onPressed: state.count == 0 && state.rounds == 0
                  ? null
                  : () => _confirmReset(context),
              icon: const Icon(Icons.restart_alt_rounded),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.tasbeehResetTitle),
        content: Text(l10n.tasbeehResetBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.actionReset),
          ),
        ],
      ),
    );
    if (ok == true) ref.read(tasbeehProvider.notifier).reset();
  }
}

class _TargetSelector extends ConsumerWidget {
  const _TargetSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final target = ref.watch(tasbeehProvider.select((s) => s.target));
    final options = {...tasbeehTargets, target}.toList();
    return Column(
      children: [
        Text(l10n.tasbeehTarget, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: AppSpace.xs),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<int>(
            showSelectedIcon: false,
            segments: [
              for (final t in options)
                ButtonSegment(value: t, label: Text(t == 0 ? l10n.tasbeehUnlimited : '$t')),
            ],
            selected: {target},
            onSelectionChanged: (s) => ref.read(tasbeehProvider.notifier).setTarget(s.first),
          ),
        ),
      ],
    );
  }
}

class _StatsRow extends ConsumerWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(tasbeehProvider);
    return Row(
      children: [
        Expanded(
          child: _Stat(label: l10n.tasbeehRounds, value: state.rounds),
        ),
        const SizedBox(width: AppSpace.xs),
        Expanded(
          child: _Stat(label: l10n.tasbeehToday, value: state.todayCount),
        ),
        const SizedBox(width: AppSpace.xs),
        Expanded(
          child: _Stat(label: l10n.tasbeehTotal, value: state.totalCount),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return AppCard(
      elevated: false,
      padding: const EdgeInsets.symmetric(vertical: AppSpace.sm, horizontal: AppSpace.xs),
      child: Column(
        children: [
          Text(
            '$value',
            style: text.titleLarge?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
          ),
          Text(label, style: text.labelSmall),
        ],
      ),
    );
  }
}

class _DhikrPickerSheet extends ConsumerWidget {
  const _DhikrPickerSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final p = context.palette;
    final options = ref.watch(tasbeehOptionsProvider);
    final state = ref.watch(tasbeehProvider);
    final controller = ref.read(tasbeehProvider.notifier);
    final arabic = Localizations.localeOf(context).languageCode == 'ar';

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.92,
      builder: (context, scroll) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.xl),
            child: Row(
              children: [
                Expanded(
                  child: Text(l10n.tasbeehChoose, style: Theme.of(context).textTheme.titleLarge),
                ),
                TextButton.icon(
                  onPressed: () => _addCustom(context, ref),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(l10n.tasbeehAddCustom),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: scroll,
              padding: const EdgeInsets.only(bottom: AppSpace.xl),
              itemCount: options.length,
              itemBuilder: (context, i) {
                final d = options[i];
                final selected = d.id == state.selectedId;
                return ListTile(
                  selected: selected,
                  selectedTileColor: p.primarySoft,
                  leading: Icon(
                    selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                    color: selected ? p.primary : p.textMuted,
                  ),
                  title: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      d.text,
                      style: AppTypography.reading(p, size: 21).copyWith(height: 1.7),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  subtitle: Text(
                    [
                      if (!arabic && d.meaningEn.isNotEmpty) d.meaningEn,
                      '${l10n.tasbeehTarget}: ${d.defaultTarget == 0 ? l10n.tasbeehUnlimited : d.defaultTarget}',
                      l10n.tasbeehStatsFor(state.totals[d.id] ?? 0),
                    ].join(' · '),
                  ),
                  trailing: d.isCustom
                      ? IconButton(
                          tooltip: l10n.tasbeehDeleteCustom,
                          onPressed: () => controller.removeCustom(d.id),
                          icon: const Icon(Icons.delete_outline_rounded),
                        )
                      : null,
                  onTap: () {
                    controller.select(d.id);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addCustom(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<(String, int)>(
      context: context,
      builder: (_) => const _CustomDhikrDialog(),
    );
    if (result == null) return;
    ref.read(tasbeehProvider.notifier).addCustom(result.$1, target: result.$2);
    if (context.mounted) Navigator.pop(context);
  }
}

class _CustomDhikrDialog extends StatefulWidget {
  const _CustomDhikrDialog();

  @override
  State<_CustomDhikrDialog> createState() => _CustomDhikrDialogState();
}

class _CustomDhikrDialogState extends State<_CustomDhikrDialog> {
  final _text = TextEditingController();
  final _target = TextEditingController(text: '33');

  @override
  void dispose() {
    _text.dispose();
    _target.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _text.text.trim();
    if (text.isEmpty) return;
    final target = (int.tryParse(_target.text) ?? 33).clamp(0, 100000);
    Navigator.pop(context, (text, target));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.tasbeehAddCustom),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _text,
            autofocus: true,
            maxLength: 120,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(hintText: l10n.tasbeehCustomHint),
          ),
          const SizedBox(height: AppSpace.xs),
          TextField(
            controller: _target,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(labelText: l10n.tasbeehCustomTarget),
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.actionCancel)),
        FilledButton(onPressed: _submit, child: Text(l10n.actionSave)),
      ],
    );
  }
}
