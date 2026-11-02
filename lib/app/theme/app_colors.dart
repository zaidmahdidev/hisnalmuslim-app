import 'package:flutter/material.dart';

/// Brand constants (identical in both themes). See docs/DESIGN_SYSTEM.md.
abstract final class BrandColors {
  static const emerald = Color(0xFF0E4D3A);
  static const emeraldDeep = Color(0xFF093629);
  static const emeraldSoft = Color(0xFF166049);
  static const gold = Color(0xFFC9A86A);
  static const ivory = Color(0xFFF7F1E3);
}

/// Semantic colour tokens, resolved per theme and exposed as a
/// [ThemeExtension] so widgets never hard-code colours.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.background,
    required this.surface,
    required this.surfaceSunken,
    required this.primary,
    required this.onPrimary,
    required this.primarySoft,
    required this.hero,
    required this.heroDeep,
    required this.onHero,
    required this.onHeroMuted,
    required this.accent,
    required this.accentSoft,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.outline,
    required this.success,
    required this.danger,
    required this.quranInk,
    required this.shadow,
  });

  static const light = AppPalette(
    background: Color(0xFFF7F3EA),
    surface: Color(0xFFFFFDF8),
    surfaceSunken: Color(0xFFEFE8DA),
    primary: BrandColors.emerald,
    onPrimary: Color(0xFFFFFFFF),
    primarySoft: Color(0xFFE1EEE7),
    hero: BrandColors.emerald,
    heroDeep: BrandColors.emeraldDeep,
    onHero: BrandColors.ivory,
    onHeroMuted: Color(0xFFC6D8CF),
    accent: Color(0xFF7E6233),
    accentSoft: Color(0xFFF1E6D0),
    textPrimary: Color(0xFF17221E),
    textSecondary: Color(0xFF4C5A54),
    textMuted: Color(0xFF5F6965),
    outline: Color(0xFFE5DCCB),
    success: Color(0xFF237A55),
    danger: Color(0xFFB0412E),
    quranInk: Color(0xFF0B4231),
    shadow: Color(0xFF0E4D3A),
  );

  static const dark = AppPalette(
    background: Color(0xFF0A1310),
    surface: Color(0xFF121E1A),
    surfaceSunken: Color(0xFF0E1916),
    primary: Color(0xFF6CC4A0),
    onPrimary: Color(0xFF052219),
    primarySoft: Color(0xFF17332A),
    hero: Color(0xFF0F3B2E),
    heroDeep: Color(0xFF0A2A21),
    onHero: BrandColors.ivory,
    onHeroMuted: Color(0xFFA8C2B6),
    accent: Color(0xFFD4B47A),
    accentSoft: Color(0xFF2E2819),
    textPrimary: Color(0xFFECE6DA),
    textSecondary: Color(0xFFB7C2BC),
    textMuted: Color(0xFF8C9993),
    outline: Color(0xFF233630),
    success: Color(0xFF6CC4A0),
    danger: Color(0xFFE48A76),
    quranInk: Color(0xFFA9DCC5),
    shadow: Color(0xFF000000),
  );

  final Color background;
  final Color surface;
  final Color surfaceSunken;
  final Color primary;
  final Color onPrimary;
  final Color primarySoft;

  /// Emerald header surfaces with the geometric pattern.
  final Color hero;
  final Color heroDeep;
  final Color onHero;
  final Color onHeroMuted;

  /// Muted gold: ornaments, highlights, never long text.
  final Color accent;
  final Color accentSoft;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color outline;
  final Color success;
  final Color danger;

  /// Ink for Quranic text inside adhkar.
  final Color quranInk;
  final Color shadow;

  @override
  AppPalette copyWith({Color? background, Color? surface, Color? primary}) => AppPalette(
    background: background ?? this.background,
    surface: surface ?? this.surface,
    surfaceSunken: surfaceSunken,
    primary: primary ?? this.primary,
    onPrimary: onPrimary,
    primarySoft: primarySoft,
    hero: hero,
    heroDeep: heroDeep,
    onHero: onHero,
    onHeroMuted: onHeroMuted,
    accent: accent,
    accentSoft: accentSoft,
    textPrimary: textPrimary,
    textSecondary: textSecondary,
    textMuted: textMuted,
    outline: outline,
    success: success,
    danger: danger,
    quranInk: quranInk,
    shadow: shadow,
  );

  @override
  AppPalette lerp(AppPalette? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      background: l(background, other.background),
      surface: l(surface, other.surface),
      surfaceSunken: l(surfaceSunken, other.surfaceSunken),
      primary: l(primary, other.primary),
      onPrimary: l(onPrimary, other.onPrimary),
      primarySoft: l(primarySoft, other.primarySoft),
      hero: l(hero, other.hero),
      heroDeep: l(heroDeep, other.heroDeep),
      onHero: l(onHero, other.onHero),
      onHeroMuted: l(onHeroMuted, other.onHeroMuted),
      accent: l(accent, other.accent),
      accentSoft: l(accentSoft, other.accentSoft),
      textPrimary: l(textPrimary, other.textPrimary),
      textSecondary: l(textSecondary, other.textSecondary),
      textMuted: l(textMuted, other.textMuted),
      outline: l(outline, other.outline),
      success: l(success, other.success),
      danger: l(danger, other.danger),
      quranInk: l(quranInk, other.quranInk),
      shadow: l(shadow, other.shadow),
    );
  }
}

extension AppPaletteContext on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}
