import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_tokens.dart';
import 'brand_mark.dart';
import 'star_badge.dart';

/// Consistent empty state: star-framed icon, title, message, optional action.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, this.message, this.action});

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpace.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StarBadge(
              color: p.primarySoft,
              outline: p.accent.withValues(alpha: 0.5),
              child: Icon(icon, size: 34, color: p.primary),
            ),
            const SizedBox(height: AppSpace.lg),
            Text(title, style: text.titleLarge, textAlign: TextAlign.center),
            if (message != null) ...[
              const SizedBox(height: AppSpace.xs),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Text(message!, style: text.bodyMedium, textAlign: TextAlign.center),
              ),
            ],
            if (action != null) ...[const SizedBox(height: AppSpace.xl), action!],
          ],
        ),
      ),
    );
  }
}

/// Error state with the same visual language as [EmptyState].
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.title, this.message, this.onRetry, this.retryLabel});

  final String title;
  final String? message;
  final VoidCallback? onRetry;
  final String? retryLabel;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.error_outline_rounded,
      title: title,
      message: message,
      action: onRetry == null
          ? null
          : OutlinedButton(onPressed: onRetry, child: Text(retryLabel ?? '')),
    );
  }
}

/// Calm loading indicator: the brand mark gently breathing.
class LoadingView extends StatefulWidget {
  const LoadingView({super.key, this.label});

  final String? label;

  @override
  State<LoadingView> createState() => _LoadingViewState();
}

class _LoadingViewState extends State<LoadingView> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        label: widget.label,
        liveRegion: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FadeTransition(
              opacity: Tween(begin: 0.45, end: 1.0).animate(_controller),
              child: const BrandMark(size: 72),
            ),
            if (widget.label != null) ...[
              const SizedBox(height: AppSpace.md),
              Text(widget.label!, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ],
        ),
      ),
    );
  }
}
