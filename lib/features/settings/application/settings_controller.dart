import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../data/models/app_settings.dart';

final settingsProvider = NotifierProvider<SettingsController, AppSettings>(SettingsController.new);

class SettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() => ref.read(settingsRepositoryProvider).load();

  Future<void> _update(AppSettings next) async {
    if (next == state) return;
    state = next;
    await ref.read(settingsRepositoryProvider).save(next);
  }

  Future<void> setThemeMode(ThemeMode mode) => _update(state.copyWith(themeMode: mode));

  /// Switching to English turns translations on (they can be hidden again).
  Future<void> setLanguage(String code) => _update(
    state.copyWith(
      languageCode: code,
      showTranslation: code == 'en' ? true : state.showTranslation,
    ),
  );

  Future<void> setReadingScale(double scale) => _update(state.copyWith(readingScale: scale));
  Future<void> setHaptics(bool value) => _update(state.copyWith(hapticsEnabled: value));
  Future<void> setSound(bool value) => _update(state.copyWith(soundEnabled: value));
  Future<void> setShowTranslation(bool value) => _update(state.copyWith(showTranslation: value));
  Future<void> setAutoAdvance(bool value) => _update(state.copyWith(autoAdvance: value));
  Future<void> setTapTextToCount(bool value) => _update(state.copyWith(tapTextToCount: value));
  Future<void> completeOnboarding() => _update(state.copyWith(onboardingDone: true));

  /// Used after "clear all data": back to defaults, onboarding shown again.
  void resetToDefaults() => state = const AppSettings();
}
