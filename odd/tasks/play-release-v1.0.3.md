# Publish Google Play release v1.0.3

## Goal

Add the bilingual public metadata required for the next immutable semantic tag and publish the already merged startup recovery and SMS prefilter to Google Play Internal Testing.

## Allowed edit surfaces

- `odd/tasks/play-release-v1.0.3.md`

## Approved public notes

- Spanish: `Evita que un fallo al verificar el presupuesto bloquee el inicio y filtra localmente los SMS antes de generar sugerencias.`
- English: `Prevents budget verification failures from blocking startup and filters SMS locally before generating suggestions.`

## Tasks

- [x] PR-1 — Confirm `v1.0.3` is the next semantic tag after immutable `v1.0.2`.
- [x] PR-2 — Record the approved bilingual public notes.
- [x] PR-3 — Commit the release metadata with one nonempty `RN-es:` and `RN-en:` trailer.
- [x] PR-4 — Verify note generation against a disposable annotated `v1.0.3` fixture.
- [ ] PR-5 — Deliver through approved issue #31 and a CI-gated pull request.
- [ ] PR-6 — Create and push annotated tag `v1.0.3` from the approved merge commit.

## Verification evidence

- Metadata commit: `c2fc40072f9355ea7534b2b87f352b9bc5a6d6c8`.
- The commit message contains exactly one nonempty raw `RN-es:` line and one nonempty raw `RN-en:` line matching the approved text.
- A disposable no-hardlink clone with its origin removed was tagged locally with an annotated fixture `v1.0.3`.
- The production generator selected `v1.0.2..v1.0.3`.
- `release_notes_es-419.txt`, `release_notes_es-ES.txt`, and `release_notes_en-US.txt` matched the approved notes byte-for-byte.
- `git diff --check origin/main..HEAD` passed.
- Only this task document differs from `origin/main`.
- The disposable clone was removed; no source repository tag or generated release-note file was created.

## Operational boundary

The tag push triggers Codemagic's `android-play-release` workflow and submits the signed AAB as a draft to the Google Play `internal` track. No production-track promotion is authorized.
