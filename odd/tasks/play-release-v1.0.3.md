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
- [ ] PR-3 — Commit the release metadata with one nonempty `RN-es:` and `RN-en:` trailer.
- [ ] PR-4 — Verify note generation against a disposable annotated `v1.0.3` fixture.
- [ ] PR-5 — Deliver through approved issue #31 and a CI-gated pull request.
- [ ] PR-6 — Create and push annotated tag `v1.0.3` from the approved merge commit.

## Operational boundary

The tag push triggers Codemagic's `android-play-release` workflow and submits the signed AAB as a draft to the Google Play `internal` track. No production-track promotion is authorized.
