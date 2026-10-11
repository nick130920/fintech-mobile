# Play Store Screenshot Operator Guide

## 1. Prerequisites

Complete these before capturing screenshots:

- The Flutter SDK must satisfy [`pubspec.yaml`](../pubspec.yaml): Flutter `>=3.47.0` with its bundled Dart SDK `>=3.13.0 <4.0.0`.
- Attach an Android phone for this workflow; capture on the physical phone rather than an emulator.
- Install Ruby and Bundler.
- The Google Play Console app for `com.money.flow` must already exist.

## 2. Windows quick path: physical Android phone

Use this path on the physical Windows workstation. A VPS without KVM is **not** used for Android screenshot capture. Do not use an emulator for this workflow.

1. Install Git for Windows, a stable Flutter SDK satisfying [`pubspec.yaml`](../pubspec.yaml), Android Studio with the Android SDK and Platform Tools, and RubyInstaller with MSYS2/DevKit plus Bundler. Open **PowerShell** and confirm the tools are available:

   ```powershell
   flutter doctor
   flutter devices
   # Optional: verifies that Android Debug Bridge sees the USB phone.
   adb devices
   ```

2. On the physical Android phone, enable **Developer options** and **USB debugging**. Connect it by USB, accept the phone's RSA debugging prompt, then rerun `flutter devices` until it shows the phone ID.

3. From PowerShell, change to the Flutter project and prepare the dependencies and test:

   ```powershell
   Set-Location "C:\work\fintech-mobile\money_flow"
   flutter pub get
   flutter test test/play_store_screenshot_harness_test.dart
   ```

4. Capture on the connected physical phone, then inspect the three PNG files:

   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File .\tool\capture_android_play_screenshots.ps1 -Device "<android-device-id>"
   Invoke-Item ".\fastlane\metadata\android\es-419\images\phoneScreenshots"
   ```

   `-ExecutionPolicy Bypass` applies only to this invocation of this repository script. Do not weaken the machine-wide or user-wide execution policy. If the directory already contains artifacts you explicitly intend to replace, append `-Force`; it removes only the three expected PNGs.

5. Install Fastlane dependencies, set an external credential for the current PowerShell process, validate read-only access, then run the explicit screenshot upload lane:

   ```powershell
   bundle install
   $env:GOOGLE_PLAY_SERVICE_ACCOUNT_JSON = "C:\Users\ExampleUser\play-console-credentials\money-flow-listing-only.json"
   bundle exec fastlane android validate_play_listing_access
   bundle exec fastlane android upload_es_419_phone_screenshots
   ```

   The credential path is a placeholder. It must be an absolute path to a JSON key outside the Git repository; do not put credentials under `C:\work\fintech-mobile`.

## 3. Create a least-privilege service account

1. In Google Cloud, use the project associated with the existing Play Console app and enable the Google Play Android Developer API.
2. Create a dedicated service account for this listing-screenshot workflow, then create and download one JSON key for it.
3. In Play Console, associate that service account with `com.money.flow`. Grant only app-scoped permissions needed to view app information and edit the store listing. Google UI role names can vary.
4. Explicitly do **not** grant permissions for production release, track or release management, financial data, users or permissions administration, or broad account access.

The service account is for listing screenshots only. It must not receive an administrator or account-wide role.

## 4. Protect the JSON key

Keep the downloaded JSON file outside the entire Git repository. Use an absolute path to the file itself, not a symlink, and restrict it to your user account:

```sh
chmod 600 /absolute/non-symlink/path/to/service-account.json
export GOOGLE_PLAY_SERVICE_ACCOUNT_JSON=/absolute/non-symlink/path/to/service-account.json
```

Never commit, paste, share, or store this JSON key in the repository. The Fastlane configuration rejects missing paths, relative paths, symlinks, non-files, and files inside the Git repository.

## 5. Capture the three local screenshots

Run all commands in this section from `money_flow`:

```sh
bundle install
flutter devices
tool/capture_android_play_screenshots.sh --device <android-device-id>
```

The capture writes exactly these generated files:

```text
fastlane/metadata/android/es-419/images/phoneScreenshots/01-welcome.png
fastlane/metadata/android/es-419/images/phoneScreenshots/02-onboarding.png
fastlane/metadata/android/es-419/images/phoneScreenshots/03-budget-setup-choice.png
```

If that screenshot directory is nonempty, the command stops. Re-run with `--force` only to replace the three expected regular PNG files; it never replaces or deletes other files:

```sh
tool/capture_android_play_screenshots.sh --device <android-device-id> --force
```

## 6. Validate access, then upload screenshots

Run this read-only validation first. It checks the credential and Play Console access without uploading binaries, metadata, images, or screenshots:

```sh
bundle exec fastlane android validate_play_listing_access
```

Visually inspect all three PNGs before proceeding. Then, and only then, run the screenshot upload:

```sh
bundle exec fastlane android upload_es_419_phone_screenshots
```

**Warning:** `upload_es_419_phone_screenshots` is the only mutating Play Console command in this workflow. It uploads only the three validated `es-419` phone screenshots.

## 7. Workflow boundaries

This automation cannot upload an APK or AAB, edit metadata text or changelogs, upload other image categories, manage tracks, promote builds, roll out a release, or release to production. `en-US` screenshots are deferred until MoneyFlow has real English product localization.

## 8. Troubleshooting

### Tooling or device

- **`flutter` is missing:** install a Flutter SDK satisfying `pubspec.yaml`, add it to `PATH`, then rerun `flutter devices`.
- **Device mismatch:** run `flutter devices` and pass the exact attached physical Android phone ID to `--device`.
- **Ruby, `bundle`, or Bundler is missing:** install Ruby and Bundler, then run `bundle install` from `money_flow`.

### Screenshot artifacts or credentials

- **Screenshot directory is nonempty:** inspect its contents; use `--force` only when replacing the three named PNG files is intended.
- **Expected PNGs are missing:** rerun capture and confirm the three filenames shown above exist and are nonempty before upload.
- **Credential path is rejected:** ensure `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` is an existing, absolute, non-symlink regular JSON file outside the whole Git repository.

## 9. Verification checklist

- [ ] `flutter devices` lists the intended physical Android phone.
- [ ] The capture completes and the three PNGs exist at the expected path.
- [ ] Open and visually inspect `01-welcome.png`, `02-onboarding.png`, and `03-budget-setup-choice.png`.
- [ ] `bundle exec fastlane android validate_play_listing_access` succeeds before any upload.
- [ ] Run the screenshot-only upload command only after the preceding checks pass.
