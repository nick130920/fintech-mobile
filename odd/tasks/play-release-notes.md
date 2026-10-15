# Google Play release notes automation

## Goal

Ensure Google Play receives current localized release notes from the exact tagged Android release instead of stale or unrelated commit ranges.

## Decisions

- Keep push builds as CI validation without Google Play publishing.
- Publish Android bundles only from semantic version tags matching `v<major>.<minor>.<patch>`.
- Generate notes from commits reachable between the previous semantic version tag and the current tagged commit.
- Require at least one `RN-es:` and one `RN-en:` trailer; do not silently fall back to technical commit subjects.
- Generate Codemagic-recognized release-note files in the workflow working directory for `es-ES`, `es-419`, and `en-US`.
- Keep the existing Google Play `internal` draft delivery behavior.

## Allowed edit surfaces

- `codemagic.yaml`
- `scripts/generate_play_release_notes.sh`
- `scripts/test_generate_play_release_notes.sh`
- `.cursor/rules/conventional-commits.mdc`
- `odd/tasks/play-release-notes.md`

## Tasks

- [x] PRN-1 — Separate Android CI push validation from tag-only Google Play delivery.
- [x] PRN-2 — Add deterministic, tested tag-range release-note generation.
- [x] PRN-3 — Validate YAML, shell behavior, integration wiring, and independent review.

## Verification evidence

- RED: `bash scripts/test_generate_play_release_notes.sh` initially failed because `scripts/generate_play_release_notes.sh` did not exist.
- GREEN: the self-contained shell suite validates bilingual chronological notes, missing-language failure, rejected non-release/non-HEAD tags, selection of the nearest reachable semantic tag over an unrelated tag, and fail-closed shallow history without an origin.
- GREEN: `python3 -c "import yaml; document=yaml.safe_load(open('codemagic.yaml')); assert document['workflows']['android-workflow']; assert document['workflows']['android-play-release']; assert document['workflows']['ios-workflow']['publishing']['app_store_connect']['beta_groups'] == ['group name 1', 'group name 2']; print('YAML parse and workflow structure OK')"` passed.
- GREEN: `bash -n scripts/generate_play_release_notes.sh && bash -n scripts/test_generate_play_release_notes.sh` passed.
- GREEN: `git diff --check` passed.
- ShellCheck was not installed locally, so it was safely skipped.
- Correction RED: the new shallow-without-origin test initially failed because the generator accepted incomplete history.
- Correction GREEN: after detecting shallow repositories and failing closed without a usable origin, `bash scripts/test_generate_play_release_notes.sh` passed.
- Correction GREEN: iOS `beta_groups` was restored to `group name 1` and `group name 2` with its origin/main publishing comments and whitespace.
- Independent re-review: PASS; no remaining HIGH or MEDIUM findings, and pre/post repository status was identical.
- Operational boundary: native macOS/Codemagic tag execution, signing, and Google Play draft publishing remain for the first real release tag.

## Commit evidence

Pending transaction-controller Conventional Commit creation.
