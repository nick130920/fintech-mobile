# Optional Budget Onboarding

## Objective

Let authenticated users postpone budget setup without blocking access to the app, while keeping budget configuration discoverable through a non-blocking dashboard reminder.

## Problem

The authenticated startup gate currently requires a current-month budget before rendering the main screen. Users who are not ready to configure a budget cannot enter the app, and there is no durable “later” state or post-skip path back to setup.

## Why

Budget setup is valuable but should not prevent users from accessing the rest of MoneyFlow. A durable skip and a visible, non-modal reminder preserve activation without coercion.

## Scope

- Add a `Skip for now` action to the budget setup choice screen.
- Persist a per-user skip decision.
- Treat `no budget + skipped` as eligible for the main screen on every startup.
- Show a non-blocking dashboard reminder while a skipped user still has no current budget.
- Keep budget setup accessible from the reminder.
- Add deterministic coverage for skip persistence, startup routing, and reminder behavior.

## Constraints

- Skipping must never re-block startup for that user.
- The reminder must be a card or banner, never a mandatory modal.
- Existing budget creation and suggestion flows must remain available.
- Preference state must not leak between authenticated users.
- Generated technical artifacts and UI copy use English unless an existing product convention requires localized Spanish copy.
- Preserve unrelated working-tree changes.

## Delivery

- Strategy: `ask-on-risk`.
- Forecast: approximately 180–300 authored changed lines across behavior and tests.
- Branch: `feat/optional-budget-onboarding`.
- Native review boundary: each committed work unit, subject to user authorization to commit.

## Tasks

- [x] **OB-1 — Persist optional onboarding state and unblock startup**
  - Route: delegated writer; multi-file write trigger.
  - Add per-user persisted skip state.
  - Add `Skip for now` to the choice screen.
  - Update the authenticated gate so a skipped user reaches `MainScreen` immediately and on later starts.
  - Checks: test cases were authored first, but RED/GREEN execution remains unavailable because Flutter is not installed.
  - Commit: pending explicit user authorization.
  - Evidence: final independent source verification approved the network-independent, per-user startup gate with lifecycle guards.

- [x] **OB-2 — Add the non-blocking dashboard reminder**
  - Route: delegated writer; multi-file write trigger.
  - Show the reminder only when the active user skipped and lacks a current budget.
  - Link the reminder to the existing budget setup flow.
  - Ensure successful setup removes the reminder.
  - Checks: focused widget tests for visibility, action, hidden states, pending identity changes, and named-route return refresh.
  - Commit: pending explicit user authorization.
  - Evidence: final independent source verification approved the reminder state and navigation corrections.

- [ ] **OB-3 — Verify the complete user journey**
  - Route: delegated verifier if writer verification is partial or native assessment requires it.
  - Verify login → optional budget onboarding → skip → home → later reminder → budget setup access.
  - Run focused Flutter tests and static diagnostics where the SDK is available.
  - Commit: not applicable unless verification requires approved fixes.

## Acceptance Criteria

1. An authenticated user without a current budget can select `Skip for now` and immediately enter the main screen.
2. Restarting or signing back in as the same user does not reopen the blocking budget onboarding.
3. Another user does not inherit the first user’s skip decision.
4. The dashboard shows a non-blocking reminder only while the active user has skipped and has no current budget.
5. The reminder opens budget setup, which remains usable.
6. Completing budget setup removes the reminder.
7. Focused tests cover the skip action, durable gate behavior, reminder visibility, and reminder action.

## Progress

- Requirements accepted from the trusted fintech-backend sibling session.
- Existing routing, persistence utilities, dashboard composition, and test seams mapped with path-level evidence.
- Feature branch created from the current branch to isolate implementation.
- Initial implementation completed across the startup gate, per-user preferences, choice screen, dashboard reminder, and focused tests.
- Independent verification returned the initial candidate for correction; OB-1 and OB-2 were closed only after the correction rounds received final structural approval.
- The correction pass reordered the durable skip before network access, added write-failure and async identity guards, refreshed the reminder after setup/user changes, and strengthened provider/navigation/order tests.
- Second independent verification confirmed network-independent skip and provider fixes, but found two remaining identity-transition defects: the authenticated startup gate was not recreated for an in-place user change, and the reminder could display a previous user's retained `FutureBuilder` data while the new lookup was pending.
- The final correction keys the authenticated handler by stable user ID, suppresses reminder output until the replacement future completes, and adds pending-user plus real route-return refresh tests.
- Final independent verification approved the candidate structurally with no unresolved HIGH/MEDIUM source defect; runtime and compilation approval remain unavailable without Flutter.

## Verification Evidence

- `git diff --check -- money_flow/lib money_flow/test`: passed.
- Pi LSP diagnostics across all eight changed source/test files: 0 warnings or errors.
- Focused Flutter tests and analysis: unavailable because `flutter` is not installed on PATH.
- First independent source review found five correction areas; network ordering, required test providers, persistence failure behavior, refresh plumbing, and most async guards were corrected.
- Second independent source review found two remaining corrections:
  1. Recreate or refresh `_AuthenticatedHandler` when the authenticated user ID changes in place.
  2. Hide or identity-bind reminder output while a replacement future is waiting so `FutureBuilder` cannot show another user's stale result.
- Native assessment was unassessable because unrelated pre-existing untracked files prevented automatic candidate scoping; independent verification was therefore required.
- Final independent result: structurally approved, with no unresolved HIGH/MEDIUM candidate defect.
- Residual gap: actual Flutter compilation, widget execution, platform persistence, and the complete production setup journey remain unverified.

## Next Step

Run the three focused Flutter tests and scoped analyzer in an SDK-enabled environment. Then record results, close OB-3 if green, and request commit authorization for the completed work unit.
