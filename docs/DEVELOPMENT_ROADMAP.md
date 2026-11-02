# Development Roadmap

## v1.0 — done (this release)

Brand identity & design system · 13-category library (329 items) with book
footnotes · reader with counter/auto-advance/translation · tasbeeh · favorites
· offline search · reminders (exact when allowed) · settings · onboarding ·
Arabic RTL + English LTR · light/dark · accessibility (text scale to 200 %,
semantics, AA contrast) · tests · release builds · store documents and
graphics.

## Before / right after launch (high priority)

1. **Scholarly content review** of the items flagged in
   `docs/content/CONTENT_VERIFICATION_REPORT.md`, then state the review in the
   app and listing.
2. **Licensing confirmation** for the text sources and Saheeh International.
3. Support e-mail in `AppInfo.supportEmail` + an in-app "report a mistake"
   action that pre-fills the dhikr id.
4. Remaining manual QA (reminder firing, Android 13/14+ prompts, TalkBack,
   reboot) — see `docs/release/TESTING_REPORT.md`.
5. iOS build on a Mac, app-level privacy manifest, App Store screenshots.

## v1.1 candidates

- Home-screen widget with the remembrance of the day (Android/iOS).
- Optional audio recitation using the official hisnmuslim.com recordings
  (licensing permitting; would add network or larger downloads — keep optional).
- English transliteration toggle (data already bundled for most items).
- Reading "focus mode" (hide chrome, larger counter).
- Per-category reminders (e.g. after-prayer) and quiet-hours.
- Export/import of favorites & settings (local file, no cloud).
- More translations (Urdu, Indonesian, French…) from hisnmuslim.com's
  official translations.

## v1.2+

- Wear OS / watchOS tasbeeh companion.
- Accessibility: TalkBack-optimised reading order for long adhkar.
- Content: second-source verification of footnotes against a printed
  edition; per-item review status shown in the reference sheet.

## Non-goals

Accounts, ads, analytics/tracking, social features, a backend for core
features.
