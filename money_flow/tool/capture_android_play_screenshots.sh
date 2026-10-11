#!/usr/bin/env bash
# Captures Spanish Android Play Store screenshots locally. It never uploads.
set -Eeuo pipefail

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
readonly PROJECT_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd -P)"
readonly TEST_FILE="$PROJECT_DIR/integration_test/play_store_screenshots_test.dart"
readonly DRIVER_FILE="$PROJECT_DIR/integration_test/play_store_screenshot_driver.dart"
readonly CANONICAL_OUTPUT_DIR="$PROJECT_DIR/fastlane/metadata/android/es-419/images/phoneScreenshots"
readonly -a EXPECTED_SCREENSHOTS=(
  '01-welcome.png'
  '02-onboarding.png'
  '03-budget-setup-choice.png'
)

DEVICE_ID=''
FORCE=false

usage() {
  cat <<'EOF'
Usage:
  capture_android_play_screenshots.sh --device <id> [--force]

Captures the three Spanish (es-419) Android phone screenshots locally with
Flutter's integration test driver. Output is always written to:
  fastlane/metadata/android/es-419/images/phoneScreenshots

No authentication, upload, release build, or signing configuration is used.

Options:
  --device <id>   Required Android device or emulator ID from `flutter devices`.
  --force         Permit replacing the three expected PNG files in a non-empty
                  output directory. Other files are never deleted or replaced.
  -h, --help      Show this help text.
EOF
}

fail() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

resolve_path() {
  local path="$1"
  local directory=''
  local target=''

  while [[ -L "$path" ]]; do
    directory="$(cd -P -- "$(dirname -- "$path")" && pwd)"
    target="$(readlink "$path")"
    if [[ "$target" = /* ]]; then
      path="$target"
    else
      path="$directory/$target"
    fi
  done

  directory="$(cd -P -- "$(dirname -- "$path")" && pwd)"
  printf '%s/%s\n' "$directory" "$(basename -- "$path")"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --device)
      [[ $# -ge 2 && -n "$2" ]] || fail '--device requires an Android device ID.'
      DEVICE_ID="$2"
      shift 2
      ;;
    --force)
      FORCE=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      fail "Unknown option: $1. Run with --help for usage."
      ;;
  esac
done

[[ -n "$DEVICE_ID" ]] || fail 'Missing required --device <id>. Run `flutter devices` to find it.'
[[ "$DEVICE_ID" =~ ^[A-Za-z0-9._:-]+$ ]] || fail 'Device IDs may contain only letters, numbers, dots, underscores, colons, and hyphens.'

if ! command -v flutter >/dev/null 2>&1; then
  fail 'Flutter was not found on PATH. Install Flutter or add its bin directory to PATH, then rerun.'
fi

[[ -f "$TEST_FILE" ]] || fail "Required integration test is missing: $TEST_FILE"
[[ -f "$DRIVER_FILE" ]] || fail "Required integration driver is missing: $DRIVER_FILE"

FLUTTER_BIN="$(resolve_path "$(command -v flutter)")"
DART_BIN="$(dirname -- "$FLUTTER_BIN")/cache/dart-sdk/bin/dart"
[[ -x "$DART_BIN" ]] || fail "Flutter's bundled Dart SDK was not found at $DART_BIN. Reinstall Flutter or repair this SDK."

if ! flutter_devices_json="$(flutter devices --machine)"; then
  fail 'Unable to query Flutter devices. Run `flutter devices` to diagnose the local Flutter installation.'
fi

if ! FLUTTER_DEVICES_JSON="$flutter_devices_json" "$DART_BIN" /dev/stdin "$DEVICE_ID" <<'DART'; then
import 'dart:convert';
import 'dart:io';

void main(List<String> arguments) {
  final devices = jsonDecode(Platform.environment['FLUTTER_DEVICES_JSON']!);
  final deviceId = arguments.single;
  final isMatchingAndroidDevice = devices is List &&
      devices.whereType<Map>().any((device) {
        final targetPlatform = device['targetPlatform'];
        return device['id'] == deviceId &&
            targetPlatform is String &&
            targetPlatform.startsWith('android');
      });
  exit(isMatchingAndroidDevice ? 0 : 1);
}
DART
  fail "No attached Android Flutter target matches device ID '$DEVICE_ID'. Run `flutter devices` and pass an Android device ID."
fi

OUTPUT_DIR="$(mkdir -p -- "$CANONICAL_OUTPUT_DIR" && cd -- "$CANONICAL_OUTPUT_DIR" && pwd -P)"
[[ "$OUTPUT_DIR" == "$CANONICAL_OUTPUT_DIR" ]] || fail "Screenshot output must resolve to the canonical project directory: $CANONICAL_OUTPUT_DIR"

if find "$OUTPUT_DIR" -mindepth 1 -maxdepth 1 -print -quit | grep -q .; then
  [[ "$FORCE" == true ]] || fail "Screenshot directory is not empty: $OUTPUT_DIR. Re-run with --force to replace only the expected PNGs."
fi

if [[ "$FORCE" == true ]]; then
  # Validate every target before removing any file. This prevents stale expected
  # PNGs from satisfying the post-capture checks if Flutter emits no replacement.
  for screenshot in "${EXPECTED_SCREENSHOTS[@]}"; do
    screenshot_path="$OUTPUT_DIR/$screenshot"
    if [[ -e "$screenshot_path" || -L "$screenshot_path" ]]; then
      [[ ! -L "$screenshot_path" && -f "$screenshot_path" ]] || fail "Expected screenshot path is not a regular file: $screenshot_path"
    fi
  done

  for screenshot in "${EXPECTED_SCREENSHOTS[@]}"; do
    screenshot_path="$OUTPUT_DIR/$screenshot"
    [[ ! -e "$screenshot_path" ]] || rm -- "$screenshot_path"
  done
fi

printf 'Capturing Play Store screenshots to: %s\n' "$OUTPUT_DIR"
printf 'Expected files: %s\n' "${EXPECTED_SCREENSHOTS[*]}"
(
  cd -- "$PROJECT_DIR"
  PLAY_STORE_SCREENSHOT_OUTPUT="$OUTPUT_DIR" flutter drive \
    --driver="integration_test/play_store_screenshot_driver.dart" \
    --target="integration_test/play_store_screenshots_test.dart" \
    --device-id="$DEVICE_ID"
)

for screenshot in "${EXPECTED_SCREENSHOTS[@]}"; do
  screenshot_path="$OUTPUT_DIR/$screenshot"
  [[ -s "$screenshot_path" ]] || fail "Capture did not produce a non-empty screenshot: $screenshot_path"
done

printf 'Capture complete. Fastlane-compatible screenshots are in: %s\n' "$OUTPUT_DIR"
