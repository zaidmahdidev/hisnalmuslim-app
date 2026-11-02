import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/localization/gen/app_localizations.dart';
import '../../../../app/providers.dart';
import '../../../../core/utils/share_helper.dart';
import '../../../../data/models/dhikr.dart';
import '../../../favorites/application/favorites_controller.dart';

/// Shared copy / share / favorite behaviour for any dhikr surface.
abstract final class DhikrActions {
  /// Plain-text form used for copy and share: the original text, its
  /// chapter and short references, never altered.
  static String plainText(Dhikr dhikr, AppLocalizations l10n, {required bool arabic}) {
    final buffer = StringBuffer(dhikr.text);
    buffer.write('\n\n[${dhikr.section(arabic: true)}]');
    if (dhikr.refs.isNotEmpty) {
      buffer.write('\n${dhikr.refs.map((r) => r.ar).join('، ')}');
    }
    if (!arabic && dhikr.translation.isNotEmpty) {
      buffer.write('\n\n${dhikr.translation}');
    }
    buffer.write('\n\n${l10n.shareFooter}');
    return buffer.toString();
  }

  static Future<void> copy(BuildContext context, WidgetRef ref, Dhikr dhikr) {
    final l10n = AppLocalizations.of(context);
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    return ShareHelper.copy(context, plainText(dhikr, l10n, arabic: arabic), l10n.copied);
  }

  static Future<void> share(BuildContext context, Dhikr dhikr) {
    final l10n = AppLocalizations.of(context);
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    return ShareHelper.share(
      context,
      plainText(dhikr, l10n, arabic: arabic),
      subject: l10n.appName,
    );
  }

  static Future<void> toggleFavorite(BuildContext context, WidgetRef ref, Dhikr dhikr) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final added = await ref.read(favoritesProvider.notifier).toggle(dhikr.id);
    await ref.read(feedbackProvider).selection();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(added ? l10n.addedToFavorites : l10n.removedFromFavorites),
          duration: const Duration(seconds: 2),
        ),
      );
  }
}

/// Heart toggle bound to the favorites state.
class FavoriteButton extends ConsumerWidget {
  const FavoriteButton({super.key, required this.dhikr, this.color});

  final Dhikr dhikr;
  final Color? color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isFavorite = ref.watch(isFavoriteProvider(dhikr.id));
    return IconButton(
      tooltip: isFavorite ? l10n.removeFromFavorites : l10n.addToFavorites,
      onPressed: () => DhikrActions.toggleFavorite(context, ref, dhikr),
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, a) => ScaleTransition(scale: a, child: child),
        child: Icon(
          isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          key: ValueKey(isFavorite),
          color: isFavorite ? Theme.of(context).colorScheme.error : color,
        ),
      ),
    );
  }
}
