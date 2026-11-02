# Design System — "The Luminous Fortress" (الحصن المضيء)

## Brand concept

*Hisn* means fortress. The mark joins three ideas from Islamic visual
heritage into one quiet symbol:

1. **The khatam** — an eight-pointed star made of two overlapping squares —
   is the fortress wall: protection, order, completeness.
2. **The pointed arch** inside it is the fortress gate and the shape of the
   mihrab: the remembrance that lets the believer in.
3. **A small point of light** in the arch: the calm that dhikr brings.

The identity is restrained on purpose: deep emerald, warm ivory and a little
muted gold; one geometric motif used sparingly; generous whitespace. Never
gold-heavy, never ornate, no heavy gradients (the only gradients are a very
soft emerald-to-deep-emerald on hero surfaces and a faint radial light on the
icon).

Source of truth for the geometry: `tool/brand/generate_icons.py` (bitmaps)
and `lib/core/widgets/geometry.dart` (in-app vector) — keep them identical.

## Colour tokens

Brand constants: emerald `#0E4D3A`, deep emerald `#093629`, soft emerald
`#166049`, gold `#C9A86A`, ivory `#F7F1E3`.

Semantic tokens (`AppPalette`, a `ThemeExtension`):

| Token | Light | Dark | Use |
|---|---|---|---|
| background | `#F7F3EA` | `#0A1310` | scaffold |
| surface | `#FFFDF8` | `#121E1A` | cards, sheets, nav bar |
| surfaceSunken | `#EFE8DA` | `#0E1916` | wells, tracks, translation box |
| primary | `#0E4D3A` | `#6CC4A0` | actions, selected states |
| onPrimary | `#FFFFFF` | `#052219` | content on primary |
| primarySoft | `#E1EEE7` | `#17332A` | icon tiles, indicators |
| hero / heroDeep | `#0E4D3A` / `#093629` | `#0F3B2E` / `#0A2A21` | headers with pattern |
| onHero / onHeroMuted | `#F7F1E3` / `#C6D8CF` | `#F7F1E3` / `#A8C2B6` | text on hero |
| accent | `#7E6233` | `#D4B47A` | ornaments, progress — not body text |
| accentSoft | `#F1E6D0` | `#2E2819` | notices |
| textPrimary / Secondary / Muted | `#17221E` / `#4C5A54` / `#5F6965` | `#ECE6DA` / `#B7C2BC` / `#8C9993` | text |
| outline | `#E5DCCB` | `#233630` | hairlines |
| success / danger | `#237A55` / `#B0412E` | `#6CC4A0` / `#E48A76` | states |
| quranInk | `#0B4231` | `#A9DCC5` | Quranic text |

Contrast (WCAG 2.1, computed — see the snippet in docs/DEVELOPMENT_LOG.md):
every text token is ≥ 4.5:1 on every surface it is used on, in both themes
(light: textPrimary ≥ 13.4, textSecondary ≥ 5.9, textMuted ≥ 4.59, accent ≥ 4.61;
dark: textMuted ≥ 5.78, accent ≥ 8.65; onHeroMuted on hero ≥ 6.6). The light
accent and muted tones were darkened during QA to reach AA.

## Typography

| Role | Family | Notes |
|---|---|---|
| UI (Arabic + Latin) | IBM Plex Sans Arabic 400/500/600/700 | `AppTypography.textTheme` |
| Adhkar | Amiri 400/700 | base 25 sp × reading scale, line height 2.0 |
| Quranic passages | Amiri Quran | base 25 sp × scale, line height 2.15, `quranInk` |

Scale: display 32 · headline 26/22 · title 19/16/14 · body 16/14/12.5 ·
label 15/13/11.5. The reading scale (0.8–1.8) multiplies on top of the
system text scale (honoured up to 200%).

Adhkar are always laid out right-to-left, even in the English UI. Text
inside ﴿ ﴾ uses the Quranic style; the book's bracketed instructions `[...]`
are muted; the book's quotation marks `(( ))` are tinted gold. The text
itself is never changed.

## Spacing, radius, motion

- Spacing (4-pt): 4, 8, 12, 16, 20, 24, 32, 48. Page gutter 20.
  Content is centred and capped at 640 (900 for the library grid).
- Radius: 10 (small), 16 (medium), 22 (cards), 30 (sheets/hero).
- Motion: 150 ms (press), 260 ms (state), 420 ms (page/progress), standard
  curve `easeOutCubic`, emphasized `easeOutBack` for celebrations only.
- Touch targets ≥ 48 dp; reader counter 88 dp; tasbeeh dial ≥ 220 dp.

## Components (`lib/core/widgets`)

`BrandMark`, `IslamicPattern`, `StarBadge`, `AppCard`, `SectionHeader`,
`ProgressRing`, `CategoryIcon`, `Pill`, `HeroSurface`, `ContentWidth`,
`EmptyState`, `ErrorView`, `LoadingView`. Feature components:
`DhikrText`, `DhikrPreviewCard`, `CounterButton`, `ReferenceSheet`,
`FavoriteButton`.

## Iconography

Material Symbols, **rounded** style only, 24 dp (20 in dense rows, 14 in
pills). Category icons sit on a soft rounded tile (`CategoryIcon`). Icons that
imply direction (`arrow_back/forward`, `chevron_right`) mirror automatically
in RTL. The brand mark is the only custom pictogram.

## States

- **Empty**: `EmptyState` — star-framed icon, title, one sentence, optional
  action (favorites, search, missing pages).
- **Loading**: `LoadingView` — the mark breathing (content loads behind the
  native splash, so this is rarely seen).
- **Error**: `ErrorView` — same visual language with a retry action.
- **Completion**: star badge with a check, short dua of acceptance.

## App icon & splash

- Launcher: emerald field with a soft radial light, gold khatam line, ivory
  arch, gold point of light. Adaptive icon (foreground + `#0E4D3A`
  background) with a monochrome layer for Android 13 themed icons.
- Splash: emerald background with the mark (Android 12+ system splash and
  legacy layer-list; iOS launch storyboard).
- Notification icon: white silhouette of the mark.
- Generated by `python tool/brand/generate_icons.py` (also writes the
  512×512 Play icon to `docs/release/store_assets/`).
