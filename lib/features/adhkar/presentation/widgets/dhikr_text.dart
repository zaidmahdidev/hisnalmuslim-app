import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../data/models/dhikr.dart';

/// Renders the Arabic text of a dhikr without altering it:
/// Quranic passages (﴿…﴾) use the Quranic typeface and ink, the book's
/// instructions in square brackets are muted, and the book's quotation
/// marks "(( ))" are softened. Always right-to-left, even in the English UI.
class DhikrText extends StatelessWidget {
  const DhikrText({
    super.key,
    required this.dhikr,
    this.scale = 1,
    this.size,
    this.maxLines,
    this.textAlign,
  });

  final Dhikr dhikr;
  final double scale;
  final double? size;
  final int? maxLines;
  final TextAlign? textAlign;

  static final RegExp _segments = RegExp(r'(﴿[^﴾]*﴾)|(\[[^\]]*\])|(\(\(|\)\))');

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final base = dhikr.isQuran
        ? AppTypography.quran(p, scale: scale, size: size)
        : AppTypography.reading(p, scale: scale, size: size);
    final quran = AppTypography.quran(p, scale: scale, size: size);
    final muted = base.copyWith(color: p.textMuted, fontSize: base.fontSize! * 0.82);
    final marks = base.copyWith(color: p.accent);

    final spans = <InlineSpan>[];
    var last = 0;
    for (final m in _segments.allMatches(dhikr.text)) {
      if (m.start > last) spans.add(TextSpan(text: dhikr.text.substring(last, m.start)));
      final style = m.group(1) != null ? quran : (m.group(2) != null ? muted : marks);
      spans.add(TextSpan(text: m.group(0), style: style));
      last = m.end;
    }
    if (last < dhikr.text.length) spans.add(TextSpan(text: dhikr.text.substring(last)));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Text.rich(
        TextSpan(style: base, children: spans),
        // Centred, not justified: Flutter justifies Arabic by stretching spaces
        // (no kashida), which leaves uneven gaps in long adhkar.
        textAlign: textAlign ?? TextAlign.center,
        maxLines: maxLines,
        overflow: maxLines == null ? null : TextOverflow.ellipsis,
        // Arabic diacritics need the full line height; never clip them.
        textHeightBehavior: const TextHeightBehavior(
          leadingDistribution: TextLeadingDistribution.even,
        ),
      ),
    );
  }
}
