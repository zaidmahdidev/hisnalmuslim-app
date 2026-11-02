import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

/// Thin wrappers over the clipboard and the system share sheet.
abstract final class ShareHelper {
  static Future<void> copy(BuildContext context, String text, String confirmation) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(confirmation), duration: const Duration(seconds: 2)));
  }

  static Future<void> share(BuildContext context, String text, {String? subject}) async {
    // iPad needs an anchor rectangle for the share popover.
    final box = context.findRenderObject() as RenderBox?;
    final origin = box != null && box.hasSize ? box.localToGlobal(Offset.zero) & box.size : null;
    await SharePlus.instance.share(
      ShareParams(text: text, subject: subject, sharePositionOrigin: origin),
    );
  }
}
