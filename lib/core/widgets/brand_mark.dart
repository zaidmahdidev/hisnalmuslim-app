import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import 'geometry.dart';

/// The Hisn al-Muslim mark: khatam star (fortress wall), pointed arch (gate)
/// and a point of light. Vector-drawn so it is crisp at any size.
class BrandMark extends StatelessWidget {
  const BrandMark({
    super.key,
    this.size = 64,
    this.starFill = BrandColors.emeraldSoft,
    this.line = BrandColors.gold,
    this.arch = BrandColors.ivory,
    this.light = BrandColors.gold,
  });

  /// A single-colour silhouette (e.g. on coloured surfaces).
  const BrandMark.mono({super.key, this.size = 64, required Color color})
    : starFill = Colors.transparent,
      line = color,
      arch = color,
      light = Colors.transparent;

  final double size;
  final Color starFill;
  final Color line;
  final Color arch;
  final Color light;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _BrandMarkPainter(starFill: starFill, line: line, arch: arch, light: light),
        ),
      ),
    );
  }
}

class _BrandMarkPainter extends CustomPainter {
  const _BrandMarkPainter({
    required this.starFill,
    required this.line,
    required this.arch,
    required this.light,
  });

  final Color starFill;
  final Color line;
  final Color arch;
  final Color light;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    // Leave room for the stroke so the points are not clipped.
    final r = size.shortestSide * 0.46;
    final stroke = r * 0.06;
    final star = BrandGeometry.star(c, r);
    canvas.drawPath(star, Paint()..color = starFill);
    canvas.drawPath(
      star,
      Paint()
        ..color = line
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeJoin = StrokeJoin.round,
    );
    if (starFill != Colors.transparent) {
      canvas.drawPath(
        BrandGeometry.star(c, r * 0.86),
        Paint()
          ..color = line.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke / 3,
      );
    }
    canvas.drawPath(BrandGeometry.arch(c, r), Paint()..color = arch);
    canvas.drawPath(
      BrandGeometry.star(c.translate(0, -0.17 * r), 0.10 * r),
      Paint()..color = light,
    );
  }

  @override
  bool shouldRepaint(_BrandMarkPainter old) =>
      old.starFill != starFill || old.line != line || old.arch != arch || old.light != light;
}
