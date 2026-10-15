#!/usr/bin/env bash
# Self-contained tests for scripts/generate_play_release_notes.sh.
set -Eeuo pipefail
IFS=$'\n\t'

script_dir="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
generator="$script_dir/generate_play_release_notes.sh"
tmpdir="$(mktemp -d "${TMPDIR:-/tmp}/play-release-notes-test.XXXXXX")"

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
    CM_TAG="$tag" "$generator"
  )
}

test_bilingual_notes_are_chronological() {
  local repo expected
  repo="$(new_repo chronological)"
  git -C "$repo" tag v1.0.0
  commit_with_notes "$repo" first 'Primera mejora visible.' 'First visible improvement.'
  commit_with_notes "$repo" second 'Segunda mejora visible.' 'Second visible improvement.'
  git -C "$repo" tag v1.1.0

  run_generator "$repo" v1.1.0

  expected="$tmpdir/expected-es.txt"
  printf '%s\n' '- Primera mejora visible.' '- Segunda mejora visible.' > "$expected"
  assert_file_equals "$expected" "$repo/release_notes_es-ES.txt"
  assert_file_equals "$expected" "$repo/release_notes_es-419.txt"

  expected="$tmpdir/expected-en.txt"
  printf '%s\n' '- First visible improvement.' '- Second visible improvement.' > "$expected"
  assert_file_equals "$expected" "$repo/release_notes_en-US.txt"
}

test_missing_language_fails() {
  local repo output
  repo="$(new_repo missing-language)"
  printf 'spanish only\n' >> "$repo/changes.txt"
  git -C "$repo" add changes.txt
  git -C "$repo" commit -q -m 'feat: spanish only' -m 'RN-es: Mejora disponible.'
  git -C "$repo" tag v1.0.0
  output="$tmpdir/missing-language.out"

  if run_generator "$repo" v1.0.0 >"$output" 2>&1; then
    fail 'generator accepted release notes with a missing language'
  fi
  grep -F 'Missing required release-note trailer(s): RN-en:' "$output" >/dev/null || \
    fail 'missing-language error did not name RN-en:'
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

test_shallow_repository_without_origin_fails_closed() {
  local source shallow output
  source="$(new_repo shallow-source)"
  git -C "$source" tag v1.0.0
  commit_with_notes "$source" release 'Mejora de lanzamiento.' 'Release improvement.'
  git -C "$source" tag v1.1.0

  shallow="$tmpdir/shallow-without-origin"
  git clone -q --depth 1 "file://$source" "$shallow"
  git -C "$shallow" remote remove origin
  output="$tmpdir/shallow-without-origin.out"

  if run_generator "$shallow" v1.1.0 >"$output" 2>&1; then
    fail 'generator accepted incomplete shallow history without an origin'
  fi
  grep -F 'shallow and origin is unavailable' "$output" >/dev/null || \
    fail 'shallow-history error did not explain the unavailable origin'
}

test_bilingual_notes_are_chronological
test_missing_language_fails
test_invalid_or_non_head_tags_fail
test_previous_tag_must_be_reachable_and_nearest
test_shallow_repository_without_origin_fails_closed
printf 'PASS: generate_play_release_notes.sh\n'
