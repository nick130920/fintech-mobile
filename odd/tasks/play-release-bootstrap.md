# First Google Play release bootstrap

## Goal

Prepare the first semantic Google Play release without publishing all historical `RN-es:` and `RN-en:` trailers.

## Decision

- A release tag is intentionally manual because pushing it triggers Google Play delivery.
- When no previous reachable semantic tag exists, require an annotated semantic tag and extract `RN-es:` / `RN-en:` from its annotation only.
- After the first release, continue using commit trailers from the previous reachable semantic tag to the current tag.
- Reject a lightweight first release tag because it cannot carry explicit bootstrap notes.
- Planned first version: `v1.0.0`.
- Planned public scope: optional budget onboarding, registration confirmation/usability, and internal legal/support screens.

## Allowed edit surfaces

- `scripts/generate_play_release_notes.sh`
- `scripts/test_generate_play_release_notes.sh`
- `.cursor/rules/conventional-commits.mdc`
- `odd/tasks/play-release-bootstrap.md`

## Tasks

- [x] PRB-1 — Support annotated-tag notes for the first semantic release.
- [x] PRB-2 — Add bootstrap and regression shell coverage.
- [x] PRB-3 — Run structural checks and independent review.

## Verification evidence

- RED: `bash scripts/test_generate_play_release_notes.sh` failed before implementation because a first annotated `v1.0.0` generated notes from historical commit trailers instead of its annotation.
- GREEN: `bash scripts/test_generate_play_release_notes.sh` passes after the bootstrap implementation and covers annotated bootstrap, rejection of first lightweight/missing/blank/non-HEAD tags without outputs, later-release missing/blank bilingual rejection without outputs, ordering, unrelated tags, shallow recovery from a portable local `file://` origin, and shallow no-origin/unusable-origin fail-closed behavior without outputs.
- Cleanup boundary: the suite sets `TMPDIR` to a fixture-controlled directory for a successful bootstrap run and asserts the generator leaves it empty; this proves observable temporary-file cleanup without depending on generated private directory names. Failed pre-tempdir validations are covered by status and output-absence assertions.
- `bash -n scripts/generate_play_release_notes.sh`: passed.
- `bash -n scripts/test_generate_play_release_notes.sh`: passed.
- `bash scripts/test_generate_play_release_notes.sh`: passed.
- `git diff --check`: passed.
- ShellCheck is unavailable in this environment, so it was skipped after an availability check.
- Independent re-review: PASS with no remaining HIGH or MEDIUM findings; pre/post repository status was identical.
- Operational boundary: native macOS/Codemagic execution and the real `v1.0.0` tag publication remain pending explicit authorization.

## Commit evidence

Pending transaction-controller Conventional Commit creation.
