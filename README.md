# حصن المسلم — Hisn Al-Muslim

A calm, premium, fully offline Islamic companion for the daily adhkar and
supplications of *Hisn al-Muslim* (Fortress of the Muslim) by Sa'id ibn Ali
ibn Wahf al-Qahtani, plus supplications from the Quran.

Arabic-first (RTL) with a complete English (LTR) interface, light and dark
themes, no account, no ads, no tracking and no internet permission.

| | |
|---|---|
| Package / bundle id | `com.zaid.hisnalmuslim` |
| Version | `1.0.0+1` (see `pubspec.yaml`) |
| Flutter / Dart | 3.47.7 / 3.13.5 (the installed SDK — not upgraded) |
| Platforms | Android (primary), iOS (configured, needs a Mac to build) |

## Features

- **Home dashboard** — greeting, today's wird (morning + evening progress ring
  and streak), a time-aware suggestion, quick access, the remembrance of the
  day and every category.
- **Adhkar library** — 13 categories, 329 items: morning, evening, sleep,
  waking, after prayer, prayer, mosque, food & drink, home, travel,
  supplications from the Quran, prophetic supplications, various.
- **Reader** — large Amiri typography, Quranic passages in Amiri Quran,
  repetition counter with progress ring, auto-advance, previous/next,
  favorite, copy, share, adjustable text size, optional English translation,
  and the book's footnote (takhrij) for every referenced item.
- **Digital tasbeeh** — big responsive dial, presets and custom phrases,
  targets (33 / 100 / 1000 / unlimited), rounds, today and all-time stats,
  haptics and sound toggles; state survives restarts.
- **Favorites** — add/remove anywhere, searchable, "read all".
- **Search** — instant offline search with Arabic normalisation (diacritics,
  alef/yaa/taa-marbuta forms, tatweel) across text, chapters, categories and
  English translations.
- **Reminders** — optional morning/evening/bedtime and custom daily reminders,
  time-zone aware, permission requested only after an explanation.
- **Settings** — theme, language, text size, translation, auto-advance,
  haptics, sound, reminders, reset progress, clear all data, about, content
  sources, privacy policy, share app, licenses, version.

## Architecture (summary)

Feature-first structure with clean layering; details in
[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

```
lib/
  main.dart                 entry point only
  app/                      app shell: bootstrap, root widget, providers,
    router/                 GoRouter config, tab shell, route paths
    theme/                  design tokens, colours, typography, ThemeData
    localization/           ARB files (ar template, en) + generated code
  core/                     framework-level building blocks
    constants/ services/ storage/ utils/ widgets/
  data/                     models, data sources, repositories
  features/                 one folder per feature
    adhkar/ categories/ favorites/ home/ onboarding/
    reminders/ search/ settings/ tasbeeh/
      application/          Riverpod controllers (business logic)
      presentation/         screens and widgets (UI only)
assets/
  content/adhkar.json       generated content database (do not edit by hand)
  fonts/                    Amiri, Amiri Quran, IBM Plex Sans Arabic (+ OFL)
tool/
  content/                  content pipeline (sources + build script)
  brand/                    icon / splash generator
  store_assets/             store screenshot & feature-graphic renderer
docs/                       architecture, design system, content, release
```

State: Riverpod 3 (`Notifier`s). Navigation: go_router 18 (stateful shell).
Storage: `shared_preferences` (`SharedPreferencesWithCache`) behind a small
`KeyValueStore` interface. Notifications: `flutter_local_notifications` +
`timezone` + `flutter_timezone`. Sharing: `share_plus`. Version:
`package_info_plus`. No other runtime dependencies.

## Getting started

```bash
flutter pub get
flutter gen-l10n
flutter run
```

## Development commands

| Task | Command |
|---|---|
| Static analysis | `flutter analyze` |
| All tests | `flutter test` |
| Format | `dart format --line-length 100 lib test` |
| Regenerate localisations | `flutter gen-l10n` |
| Rebuild content database | `python tool/content/build_content.py` |
| Re-fetch Quranic passages | `python tool/content/fetch_quran.py` |
| Regenerate icons & splash | `python tool/brand/generate_icons.py` |
| Render store graphics | `flutter test tool/store_assets --update-goldens` |
| Release APK | `flutter build apk --release` |
| Release App Bundle (Play) | `flutter build appbundle --release` |

## Adding or updating religious content

Never edit `assets/content/adhkar.json` by hand and never type religious text
from memory. Read [docs/CONTENT_GUIDELINES.md](docs/CONTENT_GUIDELINES.md)
first. In short:

1. Put or refresh source files in `tool/content/sources/`.
2. Change mappings / overrides in `tool/content/build_content.py`
   (Quranic passages: references only, in `fetch_quran.py`).
3. Run `python tool/content/build_content.py`.
4. Review `docs/content/CONTENT_VERIFICATION_REPORT.md` and the git diff.
5. Run `flutter test` (content integrity tests must pass).
6. Bump `CONTENT_VERSION` in the build script when ids or texts change.

Favorites and progress are stored by item id (`hm<id>`, `hm<id>.am/.pm`,
`q<surah>-<ayah>`); keep ids stable so users don't lose favorites.

## Notifications

Reminders are scheduled with `zonedSchedule` + `DateTimeComponents.time`
(repeats daily) in the device time zone. They are **exact** when the system
allows it (`SCHEDULE_EXACT_ALARM`, user-revocable; on Android 14+ the
Reminders screen offers the opt-in) and fall back to inexact alarms otherwise
— Android may defer those by hours, which is why the opt-in exists.
`USE_EXACT_ALARM` is deliberately not used. Reminders are re-synced on every
launch/resume and after language changes, and restored after reboot by the
plugin's boot receiver (declared in `AndroidManifest.xml`). The
notification icon is `android/app/src/main/res/drawable-*/ic_stat_hisn.png`.

## Releasing

See [docs/release/BUILD_INSTRUCTIONS.md](docs/release/BUILD_INSTRUCTIONS.md)
and the checklists in [docs/release/](docs/release/). Release signing reads
`android/key.properties` (git-ignored); without it the release build falls back
to the debug key, which Google Play rejects.

## Credits

- Text: *Hisn al-Muslim* — Sa'id ibn Ali ibn Wahf al-Qahtani, via
  [hisnmuslim.com](https://www.hisnmuslim.com).
- Quran text: [Tanzil](https://tanzil.net). English meaning: Saheeh
  International.
- Fonts: Amiri & Amiri Quran (The Amiri Project Authors), IBM Plex Sans
  Arabic (IBM) — SIL Open Font License 1.1.
