# Legal and support screens

## Goal

Make the registration links for Terms of Service, Privacy Policy, and Contact Us functional without depending on unpublished web pages.

## Product decisions

- Terms and Privacy open internal, scrollable screens.
- Legal copy is a provisional draft and must explicitly state that it is pending legal review.
- Contact Us opens an internal support screen.
- The official support address is `support@tatacode.com`.
- Email launch failures must produce visible feedback instead of failing silently.

## Allowed edit surfaces

- `money_flow/lib/features/auth/presentation/screens/register_screen.dart`
- `money_flow/lib/features/legal/**`
- `money_flow/test/features/auth/presentation/screens/register_screen_test.dart`
- `money_flow/test/features/legal/**`
- `odd/tasks/legal-support-screens.md`

## Tasks

- [x] LS-1 — Implement internal legal/support screens and connect registration actions.
- [x] LS-2 — Add focused widget coverage for navigation and contact behavior.
- [x] LS-3 — Run formatting, focused tests, scoped analysis, structural checks, and independent review.

## Verification evidence

- RED: focused widget tests failed before implementation because the legal screen imports and widgets did not exist.
- GREEN: `flutter test --no-pub test/features/auth/presentation/screens/register_screen_test.dart test/features/legal/legal_support_screens_test.dart` passed 14 tests, including the six existing registration tests.
- Format check: `dart format --output=none --set-exit-if-changed` passed for all changed Dart files.
- Structural check: verified registration routes to the three internal screens, the draft status copy is present, and the contact URI is `mailto:support@tatacode.com`.
- Analysis: `flutter analyze --no-pub lib/features/auth/presentation/screens/register_screen.dart lib/features/legal test/features/auth/presentation/screens/register_screen_test.dart test/features/legal` completed with no issues.
- Independent verification: PASS after removing an unsupported security assurance from the privacy draft; no remaining HIGH or MEDIUM findings.
- Repository hygiene: `git diff --check` passed and before/after status was identical.
- LSP: seven Dart files checked with no code diagnostics; three informational spellcheck suggestions incorrectly treated Spanish words as English.

## Commit evidence

Pending transaction-controller Conventional Commit creation.
