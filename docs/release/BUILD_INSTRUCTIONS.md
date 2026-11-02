# Build Instructions

Toolchain used: Flutter 3.47.7 (stable) · Dart 3.13.5 · Android SDK 36 ·
JDK 21 (Android Studio JBR) · Gradle 9.3.1 · AGP 9.1.0 · Kotlin 2.4.0.
Do not upgrade Flutter just to build; the dependency versions in
`pubspec.lock` are resolved for this SDK.

## 1. Verify

```bash
flutter pub get
flutter analyze
flutter test
```

All must pass (analysis: no issues; tests: 68 passing).

## 2. Create the upload key (once — requires you)

Google Play uses **Play App Signing**: you sign uploads with an *upload key*;
Google holds the app signing key. Create the upload keystore yourself and
keep it and its passwords safe (password manager + offline backup). Losing it
requires an upload-key reset through Play Console support.

```bash
"C:/Program Files/Android/Android Studio/jbr/bin/keytool" -genkeypair -v -keystore C:/Users/YOU/keys/hisn-almuslim-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Then copy `android/key.properties.example` to `android/key.properties` and
fill in the passwords, alias and keystore path. Both files are git-ignored
(`android/.gitignore`: `key.properties`, `**/*.jks`, `**/*.keystore`).

Without `key.properties`, release builds are signed with the **debug key**
(Gradle prints a warning). That is fine for local testing, but Play rejects
such bundles.

## 3. Versioning

`pubspec.yaml` → `version: <name>+<code>`, e.g. `1.0.0+1`.
Every upload to Play needs a higher build code (`+2`, `+3`, …). Alternatively
pass `--build-name 1.0.1 --build-number 2` on the command line.

## 4. Build for Google Play

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab` (≈ 55 MB because it
contains all ABIs; Play delivers ≈ 20 MB per device).

Optional — smaller, obfuscated Dart code (keep the symbols to read crash
stack traces):

```bash
flutter build appbundle --release --obfuscate --split-debug-info=build/symbols
```

Check the signature before uploading:

```bash
"C:/Program Files/Android/Android Studio/jbr/bin/jarsigner" -verify -verbose:summary build/app/outputs/bundle/release/app-release.aab
```

It must show your upload certificate, not `CN=Android Debug`.

## 4b. Upload to Google Play (API)

```bash
python -m pip install --user google-auth google-api-python-client
python tool/release/play_publish.py --key PATH/TO/service-account.json --track internal
```

Uploads the AAB, release notes, both listings and all graphics in one edit.
Bump the build number in `pubspec.yaml` before every new upload. Use
`--track alpha` for closed testing, `--skip-bundle` to update only the
listing. Keep the service-account JSON out of the repository.

## 5. APKs for direct testing

```bash
flutter build apk --release --split-per-abi
adb install -r build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

## 6. iOS (requires macOS with Xcode)

```bash
cd ios && pod install && cd ..
flutter build ipa --release
```

Set the Team in Xcode (Runner → Signing & Capabilities), then upload the
`.ipa` with Transporter or Xcode Organizer. See
[APP_STORE_CHECKLIST.md](APP_STORE_CHECKLIST.md).

## 7. Regenerating generated assets

| What | Command |
|---|---|
| Content database + report | `python tool/content/build_content.py` |
| Quranic passages | `python tool/content/fetch_quran.py` (needs internet) |
| Launcher icons, splash, notification icon, 512 px store icon | `python tool/brand/generate_icons.py` (needs Pillow) |
| Store screenshots + feature graphics | `flutter test tool/store_assets --update-goldens` |
| Localisations | `flutter gen-l10n` |

## Troubleshooting

- **`Could not close incremental caches … compileReleaseKotlin`** on Windows:
  happens when the project and the pub cache are on different drives.
  Already handled by `kotlin.incremental=false` in
  `android/gradle.properties`.
- **Android licences not accepted** (`flutter doctor`): run
  `flutter doctor --android-licenses`.
