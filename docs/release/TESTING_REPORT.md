# Testing Report — 1.0.0+1

Date: 2026-11-01 · Flutter 3.47.7 / Dart 3.13.5 · Windows 11 host.

## Summary

| Check | Result |
|---|---|
| `flutter analyze` | **No issues** (strict casts/raw types + extra lints) |
| `flutter test` | **68 / 68 passed** |
| Store-asset render suite (`flutter test tool/store_assets --update-goldens`) | 12 / 12 rendered |
| `flutter build appbundle --release` | **Success** (debug-signed until the upload key exists) |
| `flutter build apk --release --split-per-abi` | **Success** — arm64 21.0 MB, armv7 18.7 MB, x86_64 22.4 MB |
| Release APK on a physical device (Samsung Galaxy Note 9, Android 10) | Installed and exercised — see below |
| Content build integrity | 329 items, 13 categories, 323 with footnote/Quran reference |

## Automated tests (68)

| Suite | What it covers |
|---|---|
| `test/core/arabic_normalizer_test.dart` | tashkeel/tatweel removal, alef/yaa/taa-marbuta/hamza unification, Persian letters, punctuation, terms; `DayKey` formatting, month/year rollover |
| `test/data/content_repository_test.dart` | 13 categories, non-empty text, repeat ≥ 1, traceable sources, ordering, Quran marking, morning vs evening wording, ≥ 95 % referenced, sections, search (diacritics, alef forms, titles, English, AND semantics, id filter, empty query), daily dhikr stability, `resolve` |
| `test/data/persistence_test.dart` | settings round-trip, corrupt/out-of-range data, favorites, progress day rollover, streaks, reminders merge |
| `test/features/progress_and_favorites_test.dart` | counter caps at repeat, category completion + history + streak, day rollover, persistence across restarts, favorites toggle/order/restore/persist, favorites pseudo-category |
| `test/features/tasbeeh_controller_test.dart` | default preset, 33-round wrap, unlimited, target change, reset keeps stats, selection, custom phrases, persistence and daily reset |
| `test/features/reminders_test.dart` | permission flow, no repeated prompt, denial, time change/disable/persist, custom limit & ids, English notification text, reschedule all, exact-timing opt-in, `nextInstanceOf` (today/tomorrow/DST/month end) |
| `test/widgets/app_flow_test.dart` | onboarding → home, reader counting + auto-advance, favorites from reader to tab, search results/no results, tasbeeh taps, English LTR, Arabic RTL, dark theme, clear-all-data → onboarding, 200 % text, small phone (320×568) and tablet (1024×1366) without overflow |

### Defects found and fixed by testing

1. **Circular provider dependency** in `TasbeehController.select` (would have
   crashed when choosing a dhikr) — found by unit test.
2. **Layout overflows** on a 320-pt phone (home shortcut tiles, tasbeeh hint
   row, pills) and at 200 % text (library tiles) — found by widget tests;
   tile heights now derive from the text scale.
3. **WCAG contrast**: light `textMuted` (3.97:1) and `accent` (3.60:1) failed
   AA — darkened to ≥ 4.59:1 on all surfaces (computed, not estimated).
4. **Bidi**: tasbeeh target rendered as "33 /" in RTL — fixed.
5. **Reminder delivery window**: on device, an inexact reminder 14 h ahead
   had a +10 h 24 m window. Reminders are now exact when allowed
   (`SCHEDULE_EXACT_ALARM`), verified on device (`window=0`).
6. Content pipeline: an over-eager repeat-count heuristic and an API data
   defect (chapter 86) — fixed and documented in the verification report.

## Manual QA on a physical device (release build)

Device: Samsung SM-N960U, Android 10, 1080×2220, system dark mode.

| Area | Result |
|---|---|
| Cold start (first launch after clear) | ≈ 2.7 s to first frame, no errors in logcat |
| Onboarding (dark theme, Arabic) | Correct shaping, RTL dots, language switch, skip |
| Home | Time-aware greeting/suggestion, wird card, quick access, daily dhikr |
| Reader | Quranic typeface for Ayat al-Kursi, counter, completion haptic, auto-advance to next, progress bar, RTL navigation arrows |
| Settings | Theme/language segments, sliders and switches mirror correctly in RTL |
| Reminders | Rationale dialog shown before enabling; OS alarm registered for 06:30 next day (`dumpsys alarm`), exact after the fix |
| Offline | The release build has no INTERNET permission, so every feature exercised above ran offline by construction |

## Not yet tested — remaining manual checks

- [ ] A reminder actually **firing** and its tap opening the right reader
      (needs waiting until the scheduled time; schedule a custom reminder
      2 minutes ahead).
- [ ] Android 13+ notification permission prompt and Android 14+
      "Alarms & reminders" opt-in on a newer device (the Galaxy S22 / Android 16
      was not connected during this session).
- [ ] Reboot persistence of reminders.
- [ ] TalkBack walkthrough (semantics labels exist for the counter, tasbeeh
      dial, headers and icon buttons; a human pass is still recommended).
- [ ] iOS build and device test (requires a Mac).
- [ ] Scholarly review of content (see the verification report).

## How to reproduce

```bash
flutter analyze
flutter test
flutter build appbundle --release
flutter build apk --release --split-per-abi
adb install -r build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```
