# Play Store Assets Automation

## Objective

Create a local, repeatable Android screenshot workflow for MoneyFlow and prepare a least-privilege Fastlane Supply integration for Google Play Console.

## Problem

The available AppLaunchFlow skill only automates iOS simulator captures. MoneyFlow needs deterministic Android phone screenshots in Spanish and English, plus a safe way to validate and later upload Play Store listing assets without granting release permissions.

## Why

Repeatable captures reduce manual store-listing work, keep localized screenshots consistent, and make future listing updates auditable.

## Scope

- Generate Android phone screenshots locally for `es-419`.
- Defer `en-US` screenshots until MoneyFlow has real English product localization.
- Use deterministic demo data and bypass external services during capture.
- Store generated screenshots outside version control.
- Add Fastlane Supply configuration for listing assets only.
- Document Google Cloud and Play Console least-privilege setup.

## Non-goals

- AppLaunchFlow MCP or hosted uploads.
- iOS/App Store screenshots.
- Automatic AAB upload, track promotion, staged rollout, or production release.
- Storing Google service-account credentials in the repository.

## Constraints

- Android package: `com.money.flow`.
- No product flavors currently exist.
- Release signing uses existing `CM_KEYSTORE_*` variables and must remain unchanged.
- Google credentials must remain outside the repository.
- Existing unrelated working-tree changes must not be overwritten.
- Technical artifacts are written in English.

## Delivery

- Strategy: `ask-on-risk`.
- Forecast: approximately 320 authored changed lines, excluding generated screenshots and dependency locks.
- Commit policy: pending explicit user authorization; no commit will be created automatically.

## Test Mode

- TDD: disabled because no project or session TDD configuration was found.
- Checks: focused Flutter analysis/tests, shell syntax validation, and Fastlane configuration validation where the environment supports them.

## Tasks

- [ ] **PSA-1 — Build deterministic screenshot scenarios** *(implemented; SDK execution pending)*
  - Route: delegated writer; multi-file implementation and repository reading trigger.
  - Add an Android-oriented integration screenshot target using representative MoneyFlow screens and deterministic state.
  - Decision: generate `es-419` only; English is deferred until real product localization exists.
  - Acceptance: the target exposes ordered Spanish scenarios without network, login, SMS, or permission prompts.
  - Checks: focused Dart analysis and integration/widget checks that can run without an Android SDK.

- [x] **PSA-2 — Add local Android capture runner** *(source verification passed; device execution pending)*
  - Route: delegated writer; multi-file implementation trigger.
  - Add a defensive local script that accepts an Android device ID, runs the capture target, and writes ordered PNG files into ignored artifact directories.
  - Acceptance: invalid prerequisites fail with actionable messages; no upload occurs.
  - Checks: shell syntax validation and dry prerequisite-path validation.

- [x] **PSA-3 — Configure listing-only Fastlane Supply** *(source verification passed; Ruby execution pending)*
  - Route: delegated writer; multi-file implementation trigger.
  - Add pinned Fastlane dependencies and configuration for `com.money.flow`, with lanes limited to validating and uploading metadata/screenshots.
  - Acceptance: credentials are read from an external path or environment; binary/release uploads and production promotion are excluded.
  - Checks: configuration parse/validation when Ruby and Bundler are available; otherwise document the environmental blocker.

- [x] **PSA-4 — Verify and document operator setup** *(runtime checklist remains for an SDK-equipped host)*
  - Route: delegated verifier because command-running verification is required.
  - Document service-account creation, minimal app permissions, local credential placement, screenshot generation, validation, and explicit upload commands.
  - Acceptance: a maintainer can complete setup without committing credentials or granting release permissions.
  - Checks: focused readback, repository secret scan, and all available commands from prior tasks.

## Progress

- Exploration confirmed the package name, absence of flavors, available integration-test harness, and absence of current Fastlane/Play automation.
- User selected Fastlane Supply and initially requested phone screenshots for Spanish and English.
- After discovering that product copy is hardcoded in Spanish, the user selected Spanish-only screenshots for this iteration.
- User confirmed that the Play Console app exists and already has an AAB uploaded.
- AppLaunchFlow was rejected for Android because its documented Flutter capture path is iOS-only.

## Verification Evidence

- PSA-1 writer added three Spanish-only scenarios, but verification remains open.
- Environment discovery: Node.js and npm are present; Ruby, Fastlane, Flutter, Java, Android SDK, and ADB were not found in this session environment.
- Read-only mapping found three safe isolated scenarios: welcome, onboarding, and budget setup choice.
- Product localization is not implemented: Flutter's global delegates localize framework widgets only, while MoneyFlow screen copy remains hardcoded in Spanish.
- Independent verification failed PSA-1 because Android requires `convertFlutterSurfaceToImage()` before `takeScreenshot()`, the widget test lacks an explicit `Locale` import, and capture readiness is insufficiently deterministic.
- `git diff --check` passed; Flutter formatting, analysis, and tests remain unavailable in this environment.
- PSA-2 added a defensive `flutter drive` runner and host-side integration driver that persist the three ordered PNGs under Fastlane's `es-419` phone screenshot path.
- Shell syntax, help output, missing-Flutter failure, stale-file prevention, and non-upload behavior were verified locally.
- A real Android device run remains required for driver protocol and rendered-image validation.
- Independent verification rejected PSA-2 because the screenshot driver must use the extended driver API and Android device JSON must be parsed per device object.
- Independent verification rejected PSA-3 because credentials are not proven outside the repository and the screenshot upload input tree is not isolated to the three validated phone PNGs.
- Output is fixed to the canonical Fastlane screenshot directory; `--force` validates and removes only the three exact expected regular PNGs.
- PSA-2 final source verification passed after switching to the extended Flutter driver and structured same-object Android device matching.
- PSA-3 credential containment now covers the complete Git root, and Supply receives an isolated temporary metadata path whose direct child is `es-419`.
- PSA-3 retains explicit skips for APK, AAB, text metadata, changelogs, and listing images; no track, rollout, release, version, or promotion options exist.

- [x] **PSA-5 — Add Windows workstation workflow** *(PowerShell runtime execution pending on Windows)*
  - Route: delegated writer; PowerShell runner plus Windows documentation is a multi-file implementation.
  - Add a native PowerShell capture runner equivalent to the Bash safety boundary.
  - Extend the operator guide with exact Windows setup and execution steps using a physical Android device.
  - Acceptance: the user can complete Flutter tests, capture, Fastlane validation, and screenshot upload from Windows without KVM or VPS tooling.
  - Checks: PowerShell parsing where available, source-level parity checks, and documentation command/path validation.

## Final Verification Status

- PSA-1: source verification passed; keep pending until Flutter tests and one Android capture complete successfully.
- PSA-2: source and shell prerequisite checks passed; real-device execution remains pending.
- PSA-3: source safety checks passed; Ruby/Fastlane parsing and live read-only validation remain pending.
- PSA-4: operator guide and repository-level checks passed.
- Parent LSP diagnostics reported zero findings across the four Dart harness files.
- No private-key markers, credential-value fields, active release options, or signing changes were found.

## Next Step

On the Windows workstation, install the documented prerequisites and begin with `flutter doctor`; PowerShell parsing, Flutter tests, physical-device capture, visual PNG inspection, and Fastlane runtime validation remain pending there.
