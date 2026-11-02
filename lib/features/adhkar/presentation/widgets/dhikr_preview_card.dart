import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/localization/gen/app_localizations.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/category_icon.dart';
import '../../../../data/models/dhikr.dart';
import '../../application/progress_controller.dart';
import 'dhikr_actions.dart';
import 'dhikr_text.dart';

/// Compact card for lists (category, favorites, search): a few lines of
/// the text, repetition count, today's completion and the favorite toggle.
class DhikrPreviewCard extends ConsumerWidget {
  const DhikrPreviewCard({
    super.key,
    required this.dhikr,
    required this.onTap,
    this.index,
    this.showSection = false,
  });

  final Dhikr dhikr;
  final VoidCallback onTap;

  /// 1-based position shown in the leading badge.
  final int? index;
  final bool showSection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final p = context.palette;
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    final count = ref.watch(progressProvider.select((s) => s.countOf(dhikr.id)));
    final done = count >= dhikr.repeat;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(AppSpace.md, AppSpace.sm, AppSpace.xs, AppSpace.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (index != null) _IndexBadge(index: index!, done: done),
              if (index != null) const SizedBox(width: AppSpace.xs),
              Expanded(
                child: showSection
                    ? Text(
                        dhikr.section(arabic: arabic),
                        style: Theme.of(context).textTheme.labelMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    : const SizedBox.shrink(),
              ),
              Pill(
                label: l10n.repeatCount(dhikr.repeat),
                icon: Icons.repeat_rounded,
                color: done ? p.primarySoft : null,
                textColor: done ? p.primary : null,
              ),
              FavoriteButton(dhikr: dhikr, color: p.textMuted),
            ],
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(end: AppSpace.xs),
            child: DhikrText(dhikr: dhikr, size: 19, maxLines: 3, textAlign: TextAlign.start),
          ),
        ],
      ),
    );
  }
}

class _IndexBadge extends StatelessWidget {
  const _IndexBadge({required this.index, required this.done});

  final int index;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = AppLocalizations.of(context);
    return Semantics(
      label: done ? l10n.completedSemantics : null,
      child: AnimatedContainer(
        duration: AppMotion.medium,
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: done ? p.primary : p.surfaceSunken,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: done
            ? Icon(Icons.check_rounded, size: 18, color: p.onPrimary)
            : Text('$index', style: Theme.of(context).textTheme.labelMedium),
      ),
    );
  }
}
