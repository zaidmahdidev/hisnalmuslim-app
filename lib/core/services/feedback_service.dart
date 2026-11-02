import 'package:flutter/services.dart';

/// Tactile and audible feedback, respecting the user's settings.
///
/// Uses only built-in platform feedback (no extra dependencies). The click
/// sound follows the system "touch sounds" setting on Android.
class FeedbackService {
  const FeedbackService({required this.haptics, required this.sound});

  final bool haptics;
  final bool sound;

  /// A single count.
  Future<void> tick() async {
    if (haptics) await HapticFeedback.lightImpact();
    if (sound) await SystemSound.play(SystemSoundType.click);
  }

  /// A dhikr or tasbeeh round reached its target.
  Future<void> success() async {
    if (haptics) await HapticFeedback.heavyImpact();
    if (sound) await SystemSound.play(SystemSoundType.click);
  }

  /// Selection changes (toggles, page changes).
  Future<void> selection() async {
    if (haptics) await HapticFeedback.selectionClick();
  }
}
