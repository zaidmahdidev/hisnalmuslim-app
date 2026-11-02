# App Store (iOS) Release Checklist

Legend: ✅ done · 🔑 needs your credentials · 🌐 external account · 🍎 needs a Mac.

**Status: not built for iOS, not submitted.** This Windows machine cannot
build iOS apps; the project is configured so a Mac can take over directly.

## Configured in the project ✅

- Bundle id `com.zaid.hisnalmuslim` (Runner; tests use `.RunnerTests`).
- Display name `حصن المسلم`; `CFBundleLocalizations` ar, en.
- Portrait on iPhone, all orientations on iPad; deployment target iOS 15.0.
- App icons (all sizes, opaque 1024 marketing icon) and launch screen
  (emerald background + mark).
- Local notifications: `UNUserNotificationCenter` delegate set in
  `AppDelegate.swift`; permission requested only when a reminder is enabled.
- `ITSAppUsesNonExemptEncryption = false` (skips the export-compliance prompt).
- No usage-description strings needed (no camera, location, photos…).

## On a Mac 🍎

1. Install Xcode (current) and CocoaPods; `flutter doctor` must be green for iOS.
2. `flutter pub get && cd ios && pod install`.
3. Open `ios/Runner.xcworkspace` → Runner → Signing & Capabilities → select
   your Team 🔑 (automatic signing).
4. Recommended: add an app-level `PrivacyInfo.xcprivacy` (File → New → App
   Privacy) with `NSPrivacyTracking = false`, no tracking domains, no
   collected data types; plugin manifests are merged automatically.
5. Run on a real device; test reminders (permission prompt, delivery,
   tap-to-open), Dynamic Type, VoiceOver, dark mode.
6. `flutter build ipa --release`, upload with Transporter/Xcode.

## App Store Connect 🌐

- Apple Developer Program membership (annual fee) 🔑.
- New app: name **حصن المسلم** (or "Hisn Al-Muslim: Daily Adhkar"),
  primary language Arabic, bundle id above, SKU of your choice.
- Category: **Reference** (secondary: Lifestyle). Price: Free.
- App Privacy: **Data Not Collected**; Tracking: No.
- Age rating questionnaire → 4+.
- Description / keywords / promotional text: from
  [APP_DESCRIPTION_AR.md](APP_DESCRIPTION_AR.md) and
  [APP_DESCRIPTION_EN.md](APP_DESCRIPTION_EN.md) (keywords ≤ 100 chars).
- Screenshots: App Store requires **6.9″ (1320×2868 or 1290×2796)** iPhone
  screenshots (and 13″ iPad if iPad is supported). The 1080×1920 Play images
  do not match these sizes — capture from the iOS simulator, or change the
  frame size in `tool/store_assets/store_assets_test.dart` and re-render.
- Support URL and Privacy Policy URL (required) 🔑.
- Review notes: "Offline app; no login required. Reminders are optional."
