import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_tokens.dart';
import 'islamic_pattern.dart';

/// Centres content and caps its width on tablets / landscape.
class ContentWidth extends StatelessWidget {
  const ContentWidth({super.key, required this.child, this.maxWidth = AppSpace.maxContentWidth});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/// Emerald surface with the geometric pattern and rounded bottom corners.
class HeroSurface extends StatelessWidget {
  const HeroSurface({super.key, required this.child, this.radius = AppRadius.xl});

  final Widget child;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return ClipRRect(
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(radius)),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
            colors: [p.hero, p.heroDeep],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(child: IslamicPattern(color: p.onHero, opacity: 0.07)),
            child,
          ],
        ),
      ),
    );
  }
}
