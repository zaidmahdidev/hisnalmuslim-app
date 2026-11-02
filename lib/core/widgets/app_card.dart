import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_tokens.dart';

/// The standard elevated surface: hairline border, soft emerald-tinted
/// shadow, and an ink ripple when tappable.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding = const EdgeInsets.all(AppSpace.md),
    this.color,
    this.borderRadius = AppRadius.lgAll,
    this.elevated = true,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final BorderRadius borderRadius;
  final bool elevated;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Widget content = Padding(padding: padding, child: child);
    if (onTap != null || onLongPress != null) {
      content = InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: borderRadius,
        child: content,
      );
    }
    final card = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: Border.all(color: p.outline.withValues(alpha: isDark ? 1 : 0.8)),
        boxShadow: elevated && !isDark
            ? [
                BoxShadow(
                  color: p.shadow.withValues(alpha: 0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Material(
        color: color ?? p.surface,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: content,
      ),
    );
    if (semanticLabel == null) return card;
    return Semantics(label: semanticLabel, button: onTap != null, child: card);
  }
}
