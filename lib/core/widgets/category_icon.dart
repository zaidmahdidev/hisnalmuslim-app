import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_tokens.dart';

/// Maps content icon keys to the rounded Material icon set used across the
/// app (one family, one weight — see docs/DESIGN_SYSTEM.md).
abstract final class CategoryIcons {
  static IconData of(String key) => switch (key) {
    'morning' => Icons.wb_sunny_rounded,
    'evening' => Icons.wb_twilight_rounded,
    'sleep' => Icons.bedtime_rounded,
    'waking' => Icons.light_mode_rounded,
    'after_prayer' => Icons.front_hand_rounded,
    'prayer' => Icons.self_improvement_rounded,
    'mosque' => Icons.mosque_rounded,
    'food' => Icons.restaurant_rounded,
    'home' => Icons.home_rounded,
    'travel' => Icons.luggage_rounded,
    'quran' => Icons.menu_book_rounded,
    'prophetic' => Icons.auto_awesome_rounded,
    'misc' => Icons.category_rounded,
    'favorites' => Icons.favorite_rounded,
    _ => Icons.bookmark_rounded,
  };
}

/// Icon on a soft rounded tile.
class CategoryIcon extends StatelessWidget {
  const CategoryIcon({super.key, required this.iconKey, this.size = 44, this.inverted = false});

  final String iconKey;
  final double size;

  /// Light-on-emerald variant for hero surfaces.
  final bool inverted;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: inverted ? p.onHero.withValues(alpha: 0.12) : p.primarySoft,
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      child: Icon(
        CategoryIcons.of(iconKey),
        size: size * 0.52,
        color: inverted ? p.accentSoft : p.primary,
      ),
    );
  }
}

/// Small pill showing a value such as "×3".
class Pill extends StatelessWidget {
  const Pill({super.key, required this.label, this.icon, this.color, this.textColor});

  final String label;
  final IconData? icon;
  final Color? color;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final fg = textColor ?? p.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.xs + 2, vertical: 3),
      decoration: BoxDecoration(
        color: color ?? p.surfaceSunken,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 14, color: fg), const SizedBox(width: 4)],
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: fg),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
