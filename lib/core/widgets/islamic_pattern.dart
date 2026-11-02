import 'package:flutter/material.dart';

import 'geometry.dart';

/// A subtle repeating lattice of eight-pointed stars, used sparingly on
/// emerald header surfaces. Drawn once and cached by a [RepaintBoundary].
class IslamicPattern extends StatelessWidget {
  const IslamicPattern({super.key, required this.color, this.tile = 56, this.opacity = 0.08});

  final Color color;
  final double tile;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _PatternPainter(
            color: color.withValues(alpha: opacity),
            tile: tile,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _PatternPainter extends CustomPainter {
  const _PatternPainter({required this.color, required this.tile});

  final Color color;
  final double tile;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final small = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    for (var y = -tile / 2; y < size.height + tile; y += tile) {
      for (var x = -tile / 2; x < size.width + tile; x += tile) {
        final c = Offset(x, y);
        canvas.drawPath(BrandGeometry.star(c, tile * 0.42), paint);
        // Small star in the gaps keeps the lattice continuous.
        canvas.drawPath(BrandGeometry.star(c.translate(tile / 2, tile / 2), tile * 0.14), small);
      }
    }
  }

  @override
  bool shouldRepaint(_PatternPainter old) => old.color != color || old.tile != tile;
}
