import 'package:flutter/material.dart';

import '../../../../app/localization/gen/app_localizations.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../core/widgets/progress_ring.dart';

/// The large repetition counter: a ring showing progress and the number of
/// repetitions left (or a check mark once complete).
class CounterButton extends StatefulWidget {
  const CounterButton({
    super.key,
    required this.count,
    required this.total,
    required this.onTap,
    this.onLongPress,
    this.size = AppSizes.counterButton,
  });

  final int count;
  final int total;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final double size;

  @override
  State<CounterButton> createState() => _CounterButtonState();
}

class _CounterButtonState extends State<CounterButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = AppLocalizations.of(context);
    final done = widget.count >= widget.total;
    final remaining = (widget.total - widget.count).clamp(0, widget.total);
    final text = Theme.of(context).textTheme;

    return Semantics(
      button: true,
      label: l10n.counterSemantics(widget.count, widget.total),
      hint: done ? l10n.completedSemantics : l10n.readerTapToCount,
      excludeSemantics: true,
      onTap: widget.onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: AnimatedScale(
          scale: _pressed ? 0.93 : 1,
          duration: AppMotion.fast,
          curve: AppMotion.standard,
          child: ProgressRing(
            size: widget.size,
            value: widget.total == 0 ? 0 : widget.count / widget.total,
            color: done ? p.success : p.accent,
            trackColor: p.outline,
            child: AnimatedContainer(
              duration: AppMotion.medium,
              width: widget.size - 16,
              height: widget.size - 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done ? p.success : p.primary,
                boxShadow: [
                  BoxShadow(
                    color: p.primary.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: AnimatedSwitcher(
                duration: AppMotion.fast,
                transitionBuilder: (child, a) => ScaleTransition(scale: a, child: child),
                child: done
                    ? Icon(
                        Icons.check_rounded,
                        key: const ValueKey('done'),
                        color: p.onPrimary,
                        size: 36,
                      )
                    : Column(
                        key: ValueKey(remaining),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$remaining',
                            style: text.headlineMedium?.copyWith(
                              color: p.onPrimary,
                              height: 1.05,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                          if (widget.total > 1)
                            Text(
                              l10n.readerRemainingLabel,
                              style: text.labelSmall?.copyWith(
                                color: p.onPrimary.withValues(alpha: 0.8),
                              ),
                            ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
