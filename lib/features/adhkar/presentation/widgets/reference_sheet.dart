import 'package:flutter/material.dart';

import '../../../../app/localization/gen/app_localizations.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/category_icon.dart';
import '../../../../data/models/dhikr.dart';

/// Bottom sheet with the full source information for one dhikr: reference
/// labels, the book's footnote verbatim, the book's note and provenance.
class ReferenceSheet extends StatelessWidget {
  const ReferenceSheet({super.key, required this.dhikr});

  final Dhikr dhikr;

  static Future<void> show(BuildContext context, Dhikr dhikr) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => ReferenceSheet(dhikr: dhikr),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    final arabicBody = TextStyle(
      fontFamily: AppFonts.reading,
      fontSize: 18,
      height: 1.9,
      color: p.textPrimary,
    );

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      maxChildSize: 0.92,
      builder: (context, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(AppSpace.xl, 0, AppSpace.xl, AppSpace.xxl),
        children: [
          Semantics(header: true, child: Text(l10n.readerReference, style: text.titleLarge)),
          const SizedBox(height: AppSpace.xs),
          Text(dhikr.section(arabic: arabic), style: text.bodyMedium),
          const SizedBox(height: AppSpace.md),
          if (dhikr.refs.isNotEmpty)
            Wrap(
              spacing: AppSpace.xs,
              runSpacing: AppSpace.xs,
              children: [
                for (final r in dhikr.refs)
                  Pill(
                    label: r.label(arabic: arabic),
                    icon: Icons.bookmark_rounded,
                    color: p.primarySoft,
                    textColor: p.primary,
                  ),
              ],
            ),
          const SizedBox(height: AppSpace.lg),
          if (dhikr.footnote.isNotEmpty) ...[
            Text(l10n.readerFootnoteTitle, style: text.titleSmall),
            const SizedBox(height: AppSpace.xs),
            _Box(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: SelectableText(dhikr.footnote, style: arabicBody),
              ),
            ),
          ] else
            _Box(
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: p.textMuted),
                  const SizedBox(width: AppSpace.sm),
                  Expanded(child: Text(l10n.readerReferenceMissing, style: text.bodyMedium)),
                ],
              ),
            ),
          if (dhikr.note.isNotEmpty) ...[
            const SizedBox(height: AppSpace.lg),
            Text(l10n.readerBookNote, style: text.titleSmall),
            const SizedBox(height: AppSpace.xs),
            _Box(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Text(dhikr.note, style: arabicBody),
              ),
            ),
          ],
          const SizedBox(height: AppSpace.lg),
          Text('${l10n.readerSourceLabel}: ${_sourceName(dhikr)}', style: text.bodySmall),
        ],
      ),
    );
  }

  static String _sourceName(Dhikr dhikr) {
    if (dhikr.source.startsWith('tanzil')) return 'Tanzil — tanzil.net';
    if (dhikr.source.startsWith('hisnmuslim')) {
      return 'Hisn al-Muslim — hisnmuslim.com (#${dhikr.source.split(':').last})';
    }
    return 'Hisn al-Muslim';
  }
}

class _Box extends StatelessWidget {
  const _Box({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpace.md),
      decoration: BoxDecoration(color: p.surfaceSunken, borderRadius: AppRadius.mdAll),
      child: child,
    );
  }
}
