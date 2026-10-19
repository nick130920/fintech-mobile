# SMS suggestion prefilter

## Goal

Reduce irrelevant SMS content sent for budget suggestions without silently losing genuine Colombian financial movements.

## Scope

- Filter SMS locally before the 100-message limit.
- Prefer recall over precision for ambiguous financial messages.
- Exclude clear OTP, authentication, and promotional-only messages.
- Use sender metadata as supporting evidence, never as a mandatory gate.
- Preserve the backend request contract (`body`, `date`) and newest-first ordering.
- Keep statement analysis unchanged; audit it as a later work unit.

## Tasks

- [x] SMS-1 Add RED tests for conservative Colombian SMS classification and post-filter limiting.
- [x] SMS-2 Implement a pure classifier and local filtering before the payload limit.
- [x] SMS-3 Run focused verification and independent review.

## Acceptance criteria

- Filtering happens before the 100-message cap.
- Messages are not rejected solely because their sender is unknown, their bank is absent, or their amount format differs.
- Clear OTP/security-only and promotional-only messages are excluded.
- Transaction-like messages with financial evidence are retained conservatively.
- SMS sent to the backend still contain only `body` and `date`.
- Statement suggestion behavior is unchanged.

## Evidence

- RED: the initial classifier stubs produced 21 expected failures. Four additional precedence defects were reproduced as focused failing regressions before correction.
- GREEN: 64 focused classifier/service tests pass with Flutter 3.47.5.
- Scoped analyzer: no issues found.
- `git diff --check`: passed.
- Independent final review: PASS, with no candidate-caused HIGH, MEDIUM, or LOW findings.
- The backend request remains `body` and `date`; statement behavior is unchanged.
