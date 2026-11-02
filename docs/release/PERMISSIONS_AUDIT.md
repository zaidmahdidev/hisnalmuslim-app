# Permissions & Dependencies Audit

Audited from the **merged release manifest**
(`build/app/intermediates/merged_manifest/release/.../AndroidManifest.xml`)
of build `1.0.0+1`, minSdk 24, targetSdk 36.

## Android permissions in the release build

| Permission | Declared by | Why | Runtime prompt |
|---|---|---|---|
| `POST_NOTIFICATIONS` | flutter_local_notifications | Show reminders (Android 13+) | Only when the user enables a reminder, after an in-app explanation |
| `RECEIVE_BOOT_COMPLETED` | app manifest | Restore scheduled reminders after reboot | No (normal permission) |
| `SCHEDULE_EXACT_ALARM` | app manifest | Deliver user-set reminders at the chosen minute | Android 12–13: granted at install; Android 14+: user opts in from the Reminders screen (system settings page). Revocable; without it reminders fall back to inexact alarms |
| `VIBRATE` | flutter_local_notifications | Notification vibration | No (normal permission) |
| `com.zaid.hisnalmuslim.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` | AndroidX core (auto-generated, app-private) | Internal protection of dynamically registered receivers | No |

**Not requested:** `INTERNET`, `USE_EXACT_ALARM`,
`USE_FULL_SCREEN_INTENT`, location, camera, microphone, contacts, storage,
phone, foreground service, advertising ID.

`INTERNET` appears only in the debug/profile manifests that Flutter uses for
hot reload; it is not in the release build.

Why exact alarms: verified on a device that an *inexact* reminder scheduled
14 h ahead had a delivery window of +10 h 24 m. Play's exact-alarm policy
allows `SCHEDULE_EXACT_ALARM` for user-initiated, time-specific reminders;
`USE_EXACT_ALARM` (reserved for alarm-clock/calendar apps) is not used.

Haptic feedback uses `HapticFeedback` (view-based), which needs no permission.

## iOS

No usage-description keys are needed. Notification authorisation is requested
at runtime only when a reminder is enabled. `ITSAppUsesNonExemptEncryption`
is `false` (no custom encryption).

## Runtime dependencies

| Package | Version | Purpose | Data / network |
|---|---|---|---|
| flutter_riverpod | ^3.4.3 | State management | None |
| go_router | ^18.1.2 | Navigation | None |
| shared_preferences | ^2.5.6 | Local storage | Local only |
| flutter_local_notifications | ^22.3.3 | Local reminders | Local only |
| timezone | ^0.11.2 | Time-zone database | None (bundled data) |
| flutter_timezone | ^5.1.1 | Read device time zone | Local only |
| share_plus | ^13.3.1 | System share sheet | User-initiated only |
| package_info_plus | ^10.2.2 | Show app version | None |
| intl / flutter_localizations | SDK-pinned | Localisation | None |

Dev only: flutter_test, flutter_lints. Exact resolved versions are in
`pubspec.lock`. No ads, analytics, tracking or crash-reporting SDKs.

## Re-auditing

```bash
flutter build appbundle --release
grep -o 'uses-permission[^>]*' build/app/intermediates/merged_manifest/release/*/AndroidManifest.xml
```

Re-run after adding or upgrading any plugin.
