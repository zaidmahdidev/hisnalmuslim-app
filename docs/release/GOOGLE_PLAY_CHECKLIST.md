# Google Play Release Checklist

Legend: ✅ done locally · 🔑 needs your credentials / decision · 🌐 needs
external account configuration · ⬜ to do at submission time.

**Status (2026-11-02): uploaded to INTERNAL TESTING.** Version code 1
(signed with the upload key) is on the internal track with status
*completed*; ar + en-US listings, icon, feature graphics and screenshots are
uploaded via `tool/release/play_publish.py`. The same version is prepared on
the CLOSED TESTING (alpha) track as a **draft**: Play only allows draft
releases there until the App content setup is completed in Play Console;
then press *Start rollout to Closed testing*. Not in production.

## A. Completed locally

- ✅ Application id `com.zaid.hisnalmuslim` (checked: no app with this id is
  live on Google Play on 2026-11-02).
- ✅ Version `1.0.0+1`; minSdk 24; targetSdk 36 (meets Play's target API
  requirement); compileSdk from Flutter.
- ✅ Release build config: R8 code shrinking + resource shrinking, core
  library desugaring, signing from `key.properties`.
- ✅ `flutter build appbundle --release` succeeds (signed with the debug key
  until 🔑 below is done).
- ✅ Launcher icon (adaptive + themed monochrome + legacy + round), Android 12+
  and legacy splash, notification icon.
- ✅ Localised app label: `حصن المسلم` (default) / `Hisn Al-Muslim` (en).
- ✅ Permissions minimised and audited — [PERMISSIONS_AUDIT.md](PERMISSIONS_AUDIT.md).
- ✅ No ads, analytics or tracking SDKs; no INTERNET permission.
- ✅ Store listing texts (AR/EN) within limits —
  [APP_DESCRIPTION_AR.md](APP_DESCRIPTION_AR.md), [APP_DESCRIPTION_EN.md](APP_DESCRIPTION_EN.md).
- ✅ Release notes — [RELEASE_NOTES_AR.md](RELEASE_NOTES_AR.md), [RELEASE_NOTES_EN.md](RELEASE_NOTES_EN.md).
- ✅ Data safety answers — [DATA_SAFETY_DECLARATION.md](DATA_SAFETY_DECLARATION.md).
- ✅ Privacy policy draft — [PRIVACY_POLICY.md](PRIVACY_POLICY.md).
- ✅ Graphics in `docs/release/store_assets/`:
  - `play_store_icon_512.png` — 512×512, 32-bit PNG
  - `feature_graphic/feature_graphic_ar.png`, `feature_graphic_en.png` — 1024×500
  - `screenshots/ar_01…06.png`, `en_01…04.png` — 1080×1920 phone screenshots
    rendered from the real UI (regenerate with
    `flutter test tool/store_assets --update-goldens`)
- ✅ Analysis clean, 68 automated tests passing, release build installed and
  exercised on a physical device — [TESTING_REPORT.md](TESTING_REPORT.md).

## B. Requires your credentials or decisions 🔑

- ✅ Upload keystore created outside the repo (`D:/HISN AL-MUSLIM/signing/`,
  with its passwords in `README-KEEP-SECRET.txt`) and `android/key.properties`
  written (git-ignored). 🔑 **Back up the `signing` folder offline.**
- 🔑 Choose the **developer/publisher name** shown on Play and in the privacy
  policy.
- 🔑 Provide a **support e-mail** (required by Play). Optionally set
  `AppInfo.supportEmail` in `lib/core/constants/app_info.dart` so users can
  report content mistakes in-app.
- 🔑 Confirm **content licensing** (Hisn al-Muslim text, footnote
  transcription, Saheeh International) — see
  [../CONTENT_GUIDELINES.md](../CONTENT_GUIDELINES.md#licensing--requires-the-publishers-confirmation).
- 🔑 Decide on Android backup (`allowBackup`) — see the Data safety notes.
- 🔑 Strongly recommended: have the content reviewed by a qualified scholar
  ([../content/CONTENT_VERIFICATION_REPORT.md](../content/CONTENT_VERIFICATION_REPORT.md)).

## C. Requires external account configuration 🌐

- 🌐 Google Play Developer account (one-time fee, identity verification).
  New personal accounts must run a **closed test with at least 12 testers for
  14 consecutive days** before production access — plan for it.
- 🌐 Host the privacy policy at a public URL.
- 🌐 Create the app in Play Console: default language **Arabic (ar)**, add
  English (en-US) translation; App, Free.
- 🌐 Enrol in Play App Signing (default for new apps) and upload the AAB.

## D. Play Console steps at submission ⬜

1. ⬜ Main store listing: title, short & full description (AR + EN), icon,
   feature graphic, ≥ 2 phone screenshots (use 4–8), category **Books &
   Reference** (alternative: Lifestyle), contact e-mail, privacy policy URL.
2. ⬜ App content: privacy policy, ads (No), app access (no restrictions),
   content rating questionnaire, target audience, data safety (answers in
   [DATA_SAFETY_DECLARATION.md](DATA_SAFETY_DECLARATION.md)), government app (No).
3. ⬜ Testing → Internal testing: upload AAB, add testers, smoke-test.
4. ⬜ Closed testing (if required for your account): 12+ testers × 14 days.
5. ⬜ Production: countries, release notes, roll out (consider staged
   rollout 20% → 100%).
6. ⬜ After launch: monitor Android vitals (ANRs/crashes) and reviews.

## Pre-upload sanity check

```bash
flutter analyze && flutter test && flutter build appbundle --release
"C:/Program Files/Android/Android Studio/jbr/bin/jarsigner" -verify -verbose:summary build/app/outputs/bundle/release/app-release.aab
```
