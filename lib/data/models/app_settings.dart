import 'package:flutter/material.dart';

/// User preferences. Persisted as JSON by `SettingsRepository`.
@immutable
class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.languageCode = 'ar',
    this.readingScale = 1.0,
    this.hapticsEnabled = true,
    this.soundEnabled = false,
    this.showTranslation = false,
    this.autoAdvance = true,
    this.tapTextToCount = true,
    this.onboardingDone = false,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    const defaults = AppSettings();
    return AppSettings(
      themeMode: ThemeMode.values.asNameMap()[json['themeMode']] ?? defaults.themeMode,
      languageCode: switch (json['languageCode']) {
        'en' => 'en',
        _ => 'ar',
      },
      readingScale: ((json['readingScale'] as num?)?.toDouble() ?? defaults.readingScale).clamp(
        minReadingScale,
        maxReadingScale,
      ),
      hapticsEnabled: json['hapticsEnabled'] as bool? ?? defaults.hapticsEnabled,
      soundEnabled: json['soundEnabled'] as bool? ?? defaults.soundEnabled,
      showTranslation: json['showTranslation'] as bool? ?? defaults.showTranslation,
      autoAdvance: json['autoAdvance'] as bool? ?? defaults.autoAdvance,
      tapTextToCount: json['tapTextToCount'] as bool? ?? defaults.tapTextToCount,
      onboardingDone: json['onboardingDone'] as bool? ?? defaults.onboardingDone,
    );
  }

  static const double minReadingScale = 0.8;
  static const double maxReadingScale = 1.8;

  final ThemeMode themeMode;
  final String languageCode;

  /// Multiplier applied to the reading font size (on top of system scaling).
  final double readingScale;
  final bool hapticsEnabled;
  final bool soundEnabled;
  final bool showTranslation;

  /// Move to the next dhikr automatically once its count is complete.
  final bool autoAdvance;

  /// Tapping the text card counts, not only the counter button.
  final bool tapTextToCount;
  final bool onboardingDone;

  Locale get locale => Locale(languageCode);
  bool get isArabic => languageCode == 'ar';

  AppSettings copyWith({
    ThemeMode? themeMode,
    String? languageCode,
    double? readingScale,
    bool? hapticsEnabled,
    bool? soundEnabled,
    bool? showTranslation,
    bool? autoAdvance,
    bool? tapTextToCount,
    bool? onboardingDone,
  }) => AppSettings(
    themeMode: themeMode ?? this.themeMode,
    languageCode: languageCode ?? this.languageCode,
    readingScale: (readingScale ?? this.readingScale).clamp(minReadingScale, maxReadingScale),
    hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
    soundEnabled: soundEnabled ?? this.soundEnabled,
    showTranslation: showTranslation ?? this.showTranslation,
    autoAdvance: autoAdvance ?? this.autoAdvance,
    tapTextToCount: tapTextToCount ?? this.tapTextToCount,
    onboardingDone: onboardingDone ?? this.onboardingDone,
  );

  Map<String, dynamic> toJson() => {
    'themeMode': themeMode.name,
    'languageCode': languageCode,
    'readingScale': readingScale,
    'hapticsEnabled': hapticsEnabled,
    'soundEnabled': soundEnabled,
    'showTranslation': showTranslation,
    'autoAdvance': autoAdvance,
    'tapTextToCount': tapTextToCount,
    'onboardingDone': onboardingDone,
  };

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.themeMode == themeMode &&
      other.languageCode == languageCode &&
      other.readingScale == readingScale &&
      other.hapticsEnabled == hapticsEnabled &&
      other.soundEnabled == soundEnabled &&
      other.showTranslation == showTranslation &&
      other.autoAdvance == autoAdvance &&
      other.tapTextToCount == tapTextToCount &&
      other.onboardingDone == onboardingDone;

  @override
  int get hashCode => Object.hash(
    themeMode,
    languageCode,
    readingScale,
    hapticsEnabled,
    soundEnabled,
    showTranslation,
    autoAdvance,
    tapTextToCount,
    onboardingDone,
  );
}
