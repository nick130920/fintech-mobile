# Make budget startup failures non-blocking

## Goal

Allow authenticated users to enter the app when the initial budget lookup fails, while preserving explicit per-user skip consent and retry access.

## Incident

The production `v1.0.2` app displayed `Oops! Algo salió mal` / `No pudimos verificar tu presupuesto.` and exposed only `Reintentar`. Network or non-404 API failures therefore blocked the entire authenticated experience for users without a persisted skip decision. Live TLS is restored; this change protects startup resilience rather than changing network configuration.

## Decision

- Keep the budget lookup error visible and retain `Reintentar`; do not treat lookup errors as a missing budget.
- Use the user-selected neutral Spanish action `Omitir por ahora` consistently on the error and setup-choice screens, including semantics and tests.
- Persist skip using the current authenticated numeric user ID before entering `MainScreen`.
- On persistence failure, keep recovery available and announce clear Spanish feedback. Reload platform preferences at the service boundary before trusting skip consent on every startup/retry, including remount and same-user sign-in. If reload fails, perform normal budget verification rather than trusting cached consent.
- Guard asynchronous completion against user changes, loss of authentication, and widget disposal. Budget setup remains accessible later; no shared-widget, repository, network, package-version, or preference-key changes.

## Allowed edit surfaces

1. `money_flow/lib/core/app/app_wrapper.dart`
2. `money_flow/lib/features/budget/presentation/screens/budget_setup_choice_screen.dart` — label only
3. `money_flow/test/core/app/app_wrapper_test.dart`
4. `money_flow/test/features/budget/presentation/screens/budget_setup_choice_screen_test.dart` — label only
5. `money_flow/lib/core/services/budget_onboarding_preference_service.dart`
6. `money_flow/test/core/services/budget_onboarding_preference_service_test.dart`
7. Generated/local configuration and evidence:
   - `money_flow/.dart_tool/package_config.json` — ignored; existing nine repaired SDK prefixes retained, no dependency resolution or package/key changes; not edited by this task
   - `odd/tasks/nonblocking-budget-startup.md`

## Tasks

- [x] NBS-1 — Repair the prior test draft and observe a behavior-level failure proving the lookup-error screen lacks recovery.
- [x] NBS-2 — Add user-bound `Omitir por ahora` recovery with persistence-failure handling; localize the existing choice action and tests.
- [x] NBS-3 — Fresh independent review passed with no HIGH or MEDIUM findings after correcting the failed-write optimistic-cache bypass.

## NBS-1: test-first evidence

The preference-store fake has explicit `Future<bool>` `clear`/`remove` implementations returning `true`; the draft compiles. The first test run exposed an unregistered native notification plugin. The test harness was isolated from native notifications before accepting behavior-level RED. The final harness registers an inert notification platform without changing production services or global target-platform debug state.

Before any production edit, run from the repository root:

```bash
cd money_flow && env -u HTTP_PROXY -u HTTPS_PROXY -u ALL_PROXY -u http_proxy -u https_proxy -u all_proxy /root/.cache/flutter-3.47.5/flutter/bin/flutter test --no-pub test/core/app/app_wrapper_test.dart --plain-name 'lookup error offers an accessible 48px Omitir por ahora action'
```

**RED observed:** exit 1, `Expected: exactly one matching candidate`, `Found 0 widgets with text "Omitir por ahora"`. Prior assertions confirmed `AppErrorScreen`, the Spanish lookup-error message, and `Reintentar` were present. This was not a compiler or network failure.

**GREEN observed:** the exact command above subsequently exited 0, `+1: All tests passed!`, including button semantics and minimum 48×48 size.

## NBS-2: implementation and alternate cases

`AppWrapper` retains lookup errors, offers retry plus explicit persisted skip, disables both actions during saving, and enters the real `MainScreen` only after successful persistence. Failed/throwing persistence shows `No pudimos guardar tu decisión. Inténtalo de nuevo.` in a live semantic region. The original handler-local failed-save flag protected lookup retry but did not survive remount or same-user sign-in; the service-boundary correction below supersedes that flag. Retry still immediately observes its future to avoid an unhandled fast error before FutureBuilder subscribes.

The focused tests cover persistence timing, false/throwing writes and recovery, successful retry without skip consent, confirmed missing-budget setup, stale lookup success/error after user change, stale actions after user change/sign-out, pending skip results after user change/disposal, and previously persisted skip bypass. The choice-screen implementation and its existing two tests change only the action label.

During GREEN/triangulation, tests caught semantics-handle teardown ordering, a debug-platform override invariant, and fast retry errors. All were resolved before the final checks. Scoped analysis initially identified deprecated `hasFlag` in the draft; the test now uses `flagsCollection.isLiveRegion`.

## Verification evidence

All commands below ran in the foreground with Flutter 3.47.5 / its bundled Dart. No dependency resolution was run. Tests cleared uppercase and lowercase proxy variables.

1. Formatter, run from repository root:

   ```bash
   cd money_flow && /root/.cache/flutter-3.47.5/flutter/bin/dart format lib/core/app/app_wrapper.dart lib/features/budget/presentation/screens/budget_setup_choice_screen.dart test/core/app/app_wrapper_test.dart test/features/budget/presentation/screens/budget_setup_choice_screen_test.dart
   ```

   Exit 0. Final formatting verification:

   ```bash
   cd money_flow && /root/.cache/flutter-3.47.5/flutter/bin/dart format --output=none --set-exit-if-changed lib/core/app/app_wrapper.dart lib/features/budget/presentation/screens/budget_setup_choice_screen.dart test/core/app/app_wrapper_test.dart test/features/budget/presentation/screens/budget_setup_choice_screen_test.dart
   ```

   Exit 0, `Formatted 4 files (0 changed)`.

2. Both focused test files:

   ```bash
   cd money_flow && env -u HTTP_PROXY -u HTTPS_PROXY -u ALL_PROXY -u http_proxy -u https_proxy -u all_proxy /root/.cache/flutter-3.47.5/flutter/bin/flutter test --no-pub test/core/app/app_wrapper_test.dart test/features/budget/presentation/screens/budget_setup_choice_screen_test.dart
   ```

   Exit 0, `+17: All tests passed!` after final formatting/API cleanup (15 AppWrapper tests, 2 choice-screen tests).

3. Scoped analyzer:

   ```bash
   cd money_flow && env -u HTTP_PROXY -u HTTPS_PROXY -u ALL_PROXY -u http_proxy -u https_proxy -u all_proxy /root/.cache/flutter-3.47.5/flutter/bin/flutter analyze --no-pub lib/core/app/app_wrapper.dart lib/features/budget/presentation/screens/budget_setup_choice_screen.dart test/core/app/app_wrapper_test.dart test/features/budget/presentation/screens/budget_setup_choice_screen_test.dart
   ```

   Exit 0, `No issues found!`.

4. LSP: automatic Dart diagnostics reported `Dart clean` for `app_wrapper.dart` during editing. Other edit hooks reported unavailable/silent/unconfirmed language-server coverage; no standalone LSP tool was exposed. Do not interpret those incomplete hooks as a clean four-file LSP pass. The explicit scoped analyzer above is clean.

5. Whitespace:

   ```bash
   git diff --check
   ```

   Exit 0. Unrelated pre-existing `.gitignore`, `.codegraph/`, and other task files were preserved.

## Optimistic-cache correction: test-first evidence

The installed `shared_preferences` 2.5.5 legacy implementation updates its singleton cache before calling the platform setter. Its supported `reload()` API fetches platform values before replacing that cache. No package configuration, dependency versions, preference keys, or unrelated preferences were changed.

### RED before implementation

Run from repository root:

```bash
cd money_flow && env -u HTTP_PROXY -u HTTPS_PROXY -u ALL_PROXY -u http_proxy -u https_proxy -u all_proxy /root/.cache/flutter-3.47.5/flutter/bin/flutter test --no-pub test/core/app/app_wrapper_test.dart --name 'failed skip'
```

Exit 1: all four false/throw × remount/same-numeric-user sign-in cases failed with expected budget lookup count 2, actual 1. Each test first proved failed durable persistence, optimistic cached `true`, and preservation of the exact singleton preference object across the lifecycle transition. No cache reset occurs during these transitions.

```bash
cd money_flow && env -u HTTP_PROXY -u HTTPS_PROXY -u ALL_PROXY -u http_proxy -u https_proxy -u all_proxy /root/.cache/flutter-3.47.5/flutter/bin/flutter test --no-pub test/core/services/budget_onboarding_preference_service_test.dart --name 'durable startup consent'
```

The first attempt exposed missing abstract `clear`/`remove` fake implementations (compiler failure, not behavior RED). After adding implementations that throw if invoked, the unchanged production service failed all five behavior cases: false/throw writes were trusted by a reconstructed service; failed reads bypassed absent/present/error budget verification. This second run is the service behavior RED.

### GREEN and rationale

`shouldShowBudgetSetup` now awaits `SharedPreferences.reload()` before reading the existing per-user boolean. Preference acquisition/reload/read errors fall through to normal budget verification; lookup errors remain visible rather than being converted to setup absence or navigation consent. The lookup itself is outside the preference catch. The redundant `_skipPersistenceFailed` handler flag was removed, so remount, sign-in, and retry all use the same boundary. Existing authenticated-user/disposal guards remain intact.

Both exact RED commands then exited 0: 4 AppWrapper regressions and 5 service regressions passed. Service tests also verify unrelated preferences and another user's skip remain unchanged, and that reload failure invokes budget lookup for missing budget, existing budget, and lookup error.

### Final correction verification

All commands ran in the foreground from repository root using the exact Flutter 3.47.5 SDK. Test/analyzer commands clear all six proxy variables and use `--no-pub`.

1. Formatter:

   ```bash
   cd money_flow && /root/.cache/flutter-3.47.5/flutter/bin/dart format lib/core/app/app_wrapper.dart lib/core/services/budget_onboarding_preference_service.dart lib/features/budget/presentation/screens/budget_setup_choice_screen.dart test/core/app/app_wrapper_test.dart test/core/services/budget_onboarding_preference_service_test.dart test/features/budget/presentation/screens/budget_setup_choice_screen_test.dart
   ```

   Exit 0, `Formatted 6 files (2 changed)` (only the two expanded tests needed formatting).

   ```bash
   cd money_flow && /root/.cache/flutter-3.47.5/flutter/bin/dart format --output=none --set-exit-if-changed lib/core/app/app_wrapper.dart lib/core/services/budget_onboarding_preference_service.dart lib/features/budget/presentation/screens/budget_setup_choice_screen.dart test/core/app/app_wrapper_test.dart test/core/services/budget_onboarding_preference_service_test.dart test/features/budget/presentation/screens/budget_setup_choice_screen_test.dart
   ```

   Exit 0, `Formatted 6 files (0 changed)`.

2. Focused tests:

   ```bash
   cd money_flow && env -u HTTP_PROXY -u HTTPS_PROXY -u ALL_PROXY -u http_proxy -u https_proxy -u all_proxy /root/.cache/flutter-3.47.5/flutter/bin/flutter test --no-pub test/core/app/app_wrapper_test.dart test/core/services/budget_onboarding_preference_service_test.dart test/features/budget/presentation/screens/budget_setup_choice_screen_test.dart
   ```

   Exit 0, `+32: All tests passed!`: 19 AppWrapper, 11 preference-service, 2 choice-screen tests. Pending writes, stale current-user results/actions, disposal, durable saved skip, Spanish `Omitir por ahora`, 48px error action semantics, and live-region feedback remain covered.

3. Scoped analyzer:

   ```bash
   cd money_flow && env -u HTTP_PROXY -u HTTPS_PROXY -u ALL_PROXY -u http_proxy -u https_proxy -u all_proxy /root/.cache/flutter-3.47.5/flutter/bin/flutter analyze --no-pub lib/core/app/app_wrapper.dart lib/core/services/budget_onboarding_preference_service.dart lib/features/budget/presentation/screens/budget_setup_choice_screen.dart test/core/app/app_wrapper_test.dart test/core/services/budget_onboarding_preference_service_test.dart test/features/budget/presentation/screens/budget_setup_choice_screen_test.dart
   ```

   Exit 0, `No issues found!`. Automatic editor/LSP hooks were incomplete/unavailable; this explicit analyzer is the diagnostic evidence.

4. Whitespace:

   ```bash
   git diff --check
   ```

   Exit 0 after the evidence update. Unrelated pre-existing tracked/untracked files and the ignored repaired package configuration were preserved.

## Independent review

Fresh independent verification passed with no HIGH or MEDIUM findings. It confirmed reload-before-trust, fail-closed reload handling, remount/same-user sign-in regression coverage, per-user isolation, persistence-before-navigation, authenticated-user/disposal guards, the exact `Omitir por ahora` label, live-region failure feedback, and the 48×48 minimum error action. The verifier independently observed all 32 focused tests passing, a clean six-file analyzer run, canonical formatting, and `git diff --check` success without status-visible mutations.

Physical-device screen-reader and visual testing, the broad suite, release build, and a fresh live API/TLS probe were not performed.

## Commit evidence

- `80e1ed5a69693278ebc98a1a573febf31ebcb497` — `fix(budget): make startup recovery non-blocking`
- Delivery strategy: user-selected single PR despite the 888-line review workload; the change remains one cohesive production fix with its focused regression tests and ODD evidence.
- The package configuration remains ignored/local-only.
