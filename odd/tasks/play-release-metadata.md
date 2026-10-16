# Add Google Play release metadata

## Goal

Provide bilingual commit trailers for the next immutable semantic release after `v1.0.1` failed closed during release-note generation.

## Incident

The `v1.0.1` tag annotation contained `RN-es:` and `RN-en:`, but subsequent releases intentionally read trailers from commits in the previous-tag range. Neither commit in `v1.0.0..v1.0.1` contained those trailers, so generation failed before the AAB build.

## Decision

- Keep `v1.0.1` immutable.
- Add a no-code release metadata commit with public Spanish and English trailers.
- Deliver the commit through issue, PR, CI, and merge.
- Creating and pushing `v1.0.2` remains a separate explicit publication authorization.

## Allowed edit surfaces

- `odd/tasks/play-release-metadata.md`

## Tasks

- [x] PRM-1 — Record the immutable recovery and public bilingual notes.
- [x] PRM-2 — Commit the metadata with nonempty `RN-es:` and `RN-en:` trailers.
- [x] PRM-3 — Verify generation against a temporary `v1.0.2` fixture without publishing a real tag.

## Planned public notes

- Spanish: `Corrige la preparación de la publicación en Google Play para completar correctamente el historial del repositorio.`
- English: `Fixes Google Play release preparation so the repository history is retrieved correctly.`

## Verification evidence

- Confirmed `v1.0.1` remains immutable and the recovery targets a later semantic release.
- Confirmed the planned public notes are nonempty in both required languages.
- Created commit `3e626c8274d80c7d909c9611f83e43141d485775` with exactly one nonempty `RN-es:` and one nonempty `RN-en:` trailer.
- In a disposable no-hardlink clone with no remote, created fixture-only annotated `v1.0.2` and ran the production generator with `CM_TAG=v1.0.2`.
- Generator selected `v1.0.1..v1.0.2`; both Spanish locale files and the English locale file matched the intended public notes byte-for-byte.
- Python temporary-directory cleanup completed; source repository status and tag refs remained unchanged.
- `git diff --check HEAD^ HEAD`: passed.
- Independent reassessment: PASS with no HIGH or MEDIUM findings.
- Operational boundary: the real `v1.0.2` tag remains unpublished and requires separate explicit authorization after delivery.

## Commit evidence

- `3e626c8274d80c7d909c9611f83e43141d485775` — `chore(release): add Play release metadata`
- Verification evidence was appended after the metadata commit and must be included in the same reviewable delivery branch before push.
