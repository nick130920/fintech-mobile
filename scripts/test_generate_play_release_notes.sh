#!/usr/bin/env bash
# Self-contained tests for scripts/generate_play_release_notes.sh.
set -Eeuo pipefail
IFS=$'\n\t'

script_dir="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
generator="$script_dir/generate_play_release_notes.sh"
tmpdir="$(mktemp -d "${TMPDIR:-/tmp}/play-release-notes-test.XXXXXX")"
generator_tmpdir="$tmpdir/generator-tmp"
mkdir "$generator_tmpdir"

cleanup() {
  rm -rf -- "$tmpdir"
}
trap cleanup EXIT

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

assert_file_equals() {
  local expected=$1
  local actual=$2

  if ! diff -u "$expected" "$actual"; then
    fail "unexpected contents in $actual"
  fi
}

assert_no_release_note_outputs() {
  local repo=$1
  local output

  for output in release_notes_es-ES.txt release_notes_es-419.txt release_notes_en-US.txt; do
    [[ ! -e "$repo/$output" ]] || fail "rejected generation left $output behind"
  done
}

assert_generator_tempdir_is_empty() {
  [[ -z "$(find "$generator_tmpdir" -mindepth 1 -maxdepth 1 -print -quit)" ]] || \
    fail 'generator left temporary files behind'
}

new_repo() {
  local name=$1
  local repo="$tmpdir/$name"

  git init -q "$repo"
  git -C "$repo" config user.name 'Release Notes Test'
  git -C "$repo" config user.email 'release-notes@example.invalid'
  printf 'initial\n' > "$repo/changes.txt"
  git -C "$repo" add changes.txt
  git -C "$repo" commit -q -m 'chore: initial commit'
  printf '%s\n' "$repo"
}

commit_with_notes() {
  local repo=$1
  local marker=$2
  local spanish=$3
  local english=$4

  printf '%s\n' "$marker" >> "$repo/changes.txt"
  git -C "$repo" add changes.txt
  git -C "$repo" commit -q -m "feat: $marker" -m "RN-es: $spanish" -m "RN-en: $english"
}

run_generator() {
  local repo=$1
  local tag=$2

  (
    cd "$repo"
    TMPDIR="$generator_tmpdir" CM_TAG="$tag" "$generator"
  )
}

annotated_tag_with_notes() {
  local repo=$1
  local tag=$2
  local spanish=$3
  local english=$4

  git -C "$repo" tag -a "$tag" -m 'Google Play release notes.' \
    -m "RN-es: $spanish" -m "RN-en: $english"
}

test_first_annotated_tag_uses_only_its_annotation() {
  local repo expected
  repo="$(new_repo first-annotated)"
  commit_with_notes "$repo" historical 'Nota histórica ignorada.' 'Historical note ignored.'
  annotated_tag_with_notes "$repo" v1.0.0 'Nota inicial publicada.' 'Initial published note.'

  run_generator "$repo" v1.0.0

  expected="$tmpdir/expected-first-annotated-es.txt"
  printf '%s\n' '- Nota inicial publicada.' > "$expected"
  assert_file_equals "$expected" "$repo/release_notes_es-ES.txt"
  assert_file_equals "$expected" "$repo/release_notes_es-419.txt"

  expected="$tmpdir/expected-first-annotated-en.txt"
  printf '%s\n' '- Initial published note.' > "$expected"
  assert_file_equals "$expected" "$repo/release_notes_en-US.txt"
  assert_generator_tempdir_is_empty
}

test_first_lightweight_tag_fails() {
  local repo output
  repo="$(new_repo first-lightweight)"
  commit_with_notes "$repo" historical 'Nota histórica.' 'Historical note.'
  git -C "$repo" tag v1.0.0
  output="$tmpdir/first-lightweight.out"

  if run_generator "$repo" v1.0.0 >"$output" 2>&1; then
    fail 'generator accepted a lightweight first release tag'
  fi
  grep -F 'must be an annotated tag object' "$output" >/dev/null || \
    fail 'lightweight-tag error did not require an annotated tag object'
  assert_no_release_note_outputs "$repo"
}

test_bilingual_notes_are_chronological() {
  local repo expected
  repo="$(new_repo chronological)"
  git -C "$repo" tag v1.0.0
  commit_with_notes "$repo" first 'Primera mejora visible.' 'First visible improvement.'
  commit_with_notes "$repo" second 'Segunda mejora visible.' 'Second visible improvement.'
  annotated_tag_with_notes "$repo" v1.1.0 'Anotación actual ignorada.' 'Current annotation ignored.'

  run_generator "$repo" v1.1.0

  expected="$tmpdir/expected-es.txt"
  printf '%s\n' '- Primera mejora visible.' '- Segunda mejora visible.' > "$expected"
  assert_file_equals "$expected" "$repo/release_notes_es-ES.txt"
  assert_file_equals "$expected" "$repo/release_notes_es-419.txt"

  expected="$tmpdir/expected-en.txt"
  printf '%s\n' '- First visible improvement.' '- Second visible improvement.' > "$expected"
  assert_file_equals "$expected" "$repo/release_notes_en-US.txt"
}

test_first_annotated_tag_missing_language_cannot_borrow_history() {
  local repo output
  repo="$(new_repo missing-language)"
  commit_with_notes "$repo" historical 'Nota histórica.' 'Historical English note.'
  git -C "$repo" tag -a v1.0.0 -m 'Google Play release notes.' \
    -m 'RN-es: Mejora disponible.'
  output="$tmpdir/missing-language.out"

  if run_generator "$repo" v1.0.0 >"$output" 2>&1; then
    fail 'generator accepted a first tag missing English by borrowing history'
  fi
  grep -F 'Missing required release-note annotation trailer(s): RN-en:' "$output" >/dev/null || \
    fail 'missing-language error did not name RN-en:'
  assert_no_release_note_outputs "$repo"
}

test_first_annotated_tag_blank_language_cannot_borrow_history() {
  local repo output
  repo="$(new_repo blank-language)"
  commit_with_notes "$repo" historical 'Nota histórica.' 'Historical English note.'
  git -C "$repo" tag -a v1.0.0 -m 'Google Play release notes.' \
    -m 'RN-es:' -m 'RN-en: Available improvement.'
  output="$tmpdir/blank-language.out"

  if run_generator "$repo" v1.0.0 >"$output" 2>&1; then
    fail 'generator accepted a first tag with blank Spanish by borrowing history'
  fi
  grep -F 'Missing required release-note annotation trailer(s): RN-es:' "$output" >/dev/null || \
    fail 'blank-language error did not name RN-es:'
  assert_no_release_note_outputs "$repo"
}

test_invalid_or_non_head_tags_fail() {
  local repo output
  repo="$(new_repo invalid-tags)"
  commit_with_notes "$repo" release 'Mejora de lanzamiento.' 'Release improvement.'
  git -C "$repo" tag v1.0.0
  printf 'later\n' >> "$repo/changes.txt"
  git -C "$repo" add changes.txt
  git -C "$repo" commit -q -m 'chore: later commit'
  output="$tmpdir/invalid-tags.out"

  if run_generator "$repo" preview >"$output" 2>&1; then
    fail 'generator accepted a non-release tag'
  fi
  grep -F 'not an exact semantic release tag' "$output" >/dev/null || \
    fail 'non-release-tag error was unclear'

  if run_generator "$repo" v1.0.0 >"$output" 2>&1; then
    fail 'generator accepted a tag that does not point at HEAD'
  fi
  grep -F 'does not point at HEAD' "$output" >/dev/null || \
    fail 'non-HEAD-tag error was unclear'
  assert_no_release_note_outputs "$repo"
}

assert_subsequent_release_missing_language_fails() {
  local test_name=$1
  local tag_message=$2
  local expected_missing=$3
  local repo output
  repo="$(new_repo "subsequent-${test_name}")"
  git -C "$repo" tag v1.0.0
  printf 'incomplete release\n' >> "$repo/changes.txt"
  git -C "$repo" add changes.txt
  git -C "$repo" commit -q -m 'feat: incomplete release' -m "$tag_message"
  git -C "$repo" tag v1.1.0
  output="$tmpdir/subsequent-${expected_missing}.out"

  if run_generator "$repo" v1.1.0 >"$output" 2>&1; then
    fail "generator accepted a subsequent release missing $expected_missing"
  fi
  grep -F "Missing required release-note trailer(s): $expected_missing" "$output" >/dev/null || \
    fail "subsequent-release error did not name $expected_missing"
  assert_no_release_note_outputs "$repo"
}

test_subsequent_release_missing_or_blank_language_fails() {
  assert_subsequent_release_missing_language_fails missing 'RN-es: Mejora disponible.' 'RN-en:'
  assert_subsequent_release_missing_language_fails blank 'RN-es: Mejora disponible.'$'\n\nRN-en:' 'RN-en:'
}

test_previous_tag_must_be_reachable_and_nearest() {
  local repo branch expected
  repo="$(new_repo reachable-tag)"
  branch="$(git -C "$repo" branch --show-current)"
  git -C "$repo" tag v1.0.0
  commit_with_notes "$repo" old-release 'Nota anterior.' 'Old release note.'
  git -C "$repo" tag v1.1.0

  git -C "$repo" checkout -q -b unrelated v1.0.0
  commit_with_notes "$repo" unrelated 'Nota no relacionada.' 'Unrelated note.'
  git -C "$repo" tag v9.9.9
  git -C "$repo" checkout -q "$branch"

  commit_with_notes "$repo" current-release 'Nota actual.' 'Current release note.'
  git -C "$repo" tag v1.2.0
  run_generator "$repo" v1.2.0

  expected="$tmpdir/expected-reachable.txt"
  printf '%s\n' '- Nota actual.' > "$expected"
  assert_file_equals "$expected" "$repo/release_notes_es-ES.txt"
}

new_shallow_release_repo() {
  local name=$1
  local source shallow
  source="$(new_repo "$name-source")"
  git -C "$source" tag v1.0.0
  commit_with_notes "$source" release 'Mejora de lanzamiento.' 'Release improvement.'
  git -C "$source" tag v1.1.0

  shallow="$tmpdir/$name"
  git clone -q --depth 1 "file://$source" "$shallow"
  printf '%s\n' "$shallow"
}

test_shallow_repository_recovers_from_local_origin() {
  local shallow spanish_expected english_expected
  shallow="$(new_shallow_release_repo shallow-recovery)"

  run_generator "$shallow" v1.1.0

  [[ "$(git -C "$shallow" rev-parse --is-shallow-repository)" == 'false' ]] || \
    fail 'generator did not unshallow history from the usable local origin'
  spanish_expected="$tmpdir/expected-shallow-recovery-es.txt"
  printf '%s\n' '- Mejora de lanzamiento.' > "$spanish_expected"
  assert_file_equals "$spanish_expected" "$shallow/release_notes_es-ES.txt"

  english_expected="$tmpdir/expected-shallow-recovery-en.txt"
  printf '%s\n' '- Release improvement.' > "$english_expected"
  assert_file_equals "$english_expected" "$shallow/release_notes_en-US.txt"
}

test_shallow_repository_without_origin_fails_closed() {
  local shallow output
  shallow="$(new_shallow_release_repo shallow-without-origin)"
  git -C "$shallow" remote remove origin
  output="$tmpdir/shallow-without-origin.out"

  if run_generator "$shallow" v1.1.0 >"$output" 2>&1; then
    fail 'generator accepted incomplete shallow history without an origin'
  fi
  grep -F 'shallow and origin is unavailable' "$output" >/dev/null || \
    fail 'shallow-history error did not explain the unavailable origin'
  assert_no_release_note_outputs "$shallow"
}

test_shallow_repository_with_unusable_origin_fails_closed() {
  local shallow output
  shallow="$(new_shallow_release_repo shallow-unusable-origin)"
  git -C "$shallow" remote set-url origin "file://$tmpdir/unavailable-origin"
  output="$tmpdir/shallow-unusable-origin.out"

  if run_generator "$shallow" v1.1.0 >"$output" 2>&1; then
    fail 'generator accepted incomplete shallow history with an unusable origin'
  fi
  grep -F 'could not be unshallowed from origin' "$output" >/dev/null || \
    fail 'unusable-origin error did not explain the failed recovery'
  assert_no_release_note_outputs "$shallow"
}

test_first_annotated_tag_uses_only_its_annotation
test_first_lightweight_tag_fails
test_bilingual_notes_are_chronological
test_first_annotated_tag_missing_language_cannot_borrow_history
test_first_annotated_tag_blank_language_cannot_borrow_history
test_invalid_or_non_head_tags_fail
test_subsequent_release_missing_or_blank_language_fails
test_previous_tag_must_be_reachable_and_nearest
test_shallow_repository_recovers_from_local_origin
test_shallow_repository_without_origin_fails_closed
test_shallow_repository_with_unusable_origin_fails_closed
printf 'PASS: generate_play_release_notes.sh\n'
