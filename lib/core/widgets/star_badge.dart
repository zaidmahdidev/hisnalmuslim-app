import 'package:flutter/material.dart';

import 'geometry.dart';

/// An icon framed by an eight-pointed star — the identity's illustration
/// device for onboarding, empty, error and completion states.
class StarBadge extends StatelessWidget {
  const StarBadge({
    super.key,
    required this.child,
    required this.color,
    this.outline,
    this.size = 96,
  });

  final Widget child;
  final Color color;
  final Color? outline;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _StarPainter(fill: color, outline: outline),
        child: Center(child: child),
      ),
    );
  }
}

class _StarPainter extends CustomPainter {
  const _StarPainter({required this.fill, this.outline});

  final Color fill;
  final Color? outline;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide * 0.48;
    final path = BrandGeometry.star(c, r);
    canvas.drawPath(path, Paint()..color = fill);
    if (outline case final o?) {
      canvas.drawPath(
        BrandGeometry.star(c, r * 0.84),
        Paint()
          ..color = o
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
    }
  }

  @override
  bool shouldRepaint(_StarPainter old) => old.fill != fill || old.outline != outline;
}
