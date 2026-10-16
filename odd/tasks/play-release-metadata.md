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
- [ ] PRM-2 — Commit the metadata with nonempty `RN-es:` and `RN-en:` trailers.
- [ ] PRM-3 — Verify generation against a temporary `v1.0.2` fixture without publishing a real tag.

## Planned public notes

- Spanish: `Corrige la preparación de la publicación en Google Play para completar correctamente el historial del repositorio.`
- English: `Fixes Google Play release preparation so the repository history is retrieved correctly.`

## Verification evidence

- Confirmed `v1.0.1` remains immutable and the recovery targets a later semantic release.
- Confirmed the planned public notes are nonempty in both required languages.

## Commit evidence

Pending.
