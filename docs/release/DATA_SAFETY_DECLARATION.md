# Data Safety Declaration (Google Play) & App Privacy (App Store)

Assessment based on the code and the **merged release manifest** of
`1.0.0+1` (see [PERMISSIONS_AUDIT.md](PERMISSIONS_AUDIT.md)).

## Facts the answers rely on

- No `INTERNET` permission in the release build → the app cannot transmit
  data off the device itself.
- Runtime dependencies: flutter_riverpod, go_router, shared_preferences,
  flutter_local_notifications, timezone, flutter_timezone, share_plus,
  package_info_plus, intl. None collects or transmits data.
- No ads, analytics, crash reporting, sign-in or payment SDKs.
- Local storage only: settings, favorites ids, progress counts, tasbeeh
  counts, reminder times (shared_preferences).
- Sharing uses the system share sheet, initiated by the user.

## Google Play Console → App content → Data safety

| Question | Answer |
|---|---|
| Does your app collect or share any of the required user data types? | **No** |
| Is all of the user data collected by your app encrypted in transit? | Not applicable (no data collected) |
| Do you provide a way for users to request that their data is deleted? | Not applicable; users can delete all local data in-app (Settings → Clear all app data) |

Resulting label: **"No data collected" · "No data shared with third parties"**.

Notes:

- Data processed only on the device is not "collected" under Play's
  definition.
- `android:allowBackup="true"`: Android Auto Backup may copy the app's local
  preferences into the **user's own** Google backup. This is a system service
  under the user's control, not collection by the developer. If you prefer
  zero ambiguity, set `allowBackup="false"` in `AndroidManifest.xml` (users
  would then lose favorites when changing phones). — **Publisher decision.**

## Other App content declarations (Play Console)

| Section | Answer |
|---|---|
| Privacy policy | URL of the hosted [PRIVACY_POLICY.md](PRIVACY_POLICY.md) — **required, must be filled in** |
| Ads | **No, my app does not contain ads** |
| App access | All functionality is available without special access |
| Content rating (IARC questionnaire) | Category: Reference/Education. No violence, sexuality, profanity, drugs, gambling, user-generated content or user interaction, no location sharing, no purchases → expected **Everyone / PEGI 3 / 3+** |
| Target audience | Recommend **13+** (or 18+) to avoid Families-program obligations; the content is suitable for all ages. Choosing ages under 13 triggers the Families policy — acceptable too since no data is collected, but requires extra review. |
| News app | No |
| COVID-19 contact tracing | No |
| Data safety | As above |
| Government app | No |
| Financial features | None |
| Health | None |
| Exact alarms | Uses `SCHEDULE_EXACT_ALARM` (user-granted) for user-set reminders; `USE_EXACT_ALARM` is not used, so no exact-alarm declaration form is expected. If Play Console asks, state: "user-scheduled adhkar reminders at a specific time". |
| Full-screen intent / foreground service | Not applicable (permissions not used) |

## App Store Connect → App Privacy

- **Data Not Collected** for every category.
- Tracking: **No**.
- Privacy manifest: the app itself uses `UserDefaults` only through
  shared_preferences, whose plugin ships its own `PrivacyInfo.xcprivacy`.
  Adding an app-level `PrivacyInfo.xcprivacy` (NSPrivacyTracking = false, no
  collected data types) is recommended — see
  [APP_STORE_CHECKLIST.md](APP_STORE_CHECKLIST.md).
- Age rating: 4+.
