import 'dart:math' as math;
import 'dart:ui';

/// Geometry of the brand: an eight-pointed khatam star and a pointed arch.
/// Mirrors tool/brand/generate_icons.py so in-app and launcher marks match.
abstract final class BrandGeometry {
  /// Eight-pointed star (two overlapping squares) as a closed path.
  static Path star(Offset c, double outer, {double rotation = 0}) {
    final inner = outer * math.cos(math.pi / 4) / math.cos(math.pi / 8);
    final path = Path();
    for (var k = 0; k < 16; k++) {
      final r = k.isEven ? outer : inner;
      final a = rotation - math.pi / 2 + k * math.pi / 8;
      final p = Offset(c.dx + r * math.cos(a), c.dy + r * math.sin(a));
      k == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    return path..close();
  }

  /// Pointed (two-centred) arch sized relative to the star radius [r].
  static Path arch(Offset c, double r, {int steps = 32}) {
    final a = 0.30 * r;
    final base = c.dy + 0.47 * r;
    final spring = c.dy - 0.02 * r;
    final apex = c.dy - 0.50 * r;
    final h = spring - apex;
    final radius = (a * a + h * h) / (2 * a);
    final centreX = c.dx - a + radius; // centre of the left-hand arc
    var end = math.atan2(apex - spring, c.dx - centreX);
    if (end < 0) end += 2 * math.pi;
    final left = <Offset>[
      for (var i = 0; i <= steps; i++)
        Offset(
          centreX + radius * math.cos(math.pi + (end - math.pi) * i / steps),
          spring + radius * math.sin(math.pi + (end - math.pi) * i / steps),
        ),
    ];
    final path = Path()..moveTo(c.dx - a, base);
    for (final p in left) {
      path.lineTo(p.dx, p.dy);
    }
    for (final p in left.reversed.skip(1)) {
      path.lineTo(2 * c.dx - p.dx, p.dy);
    }
    return path
      ..lineTo(c.dx + a, base)
      ..close();
  }
}
