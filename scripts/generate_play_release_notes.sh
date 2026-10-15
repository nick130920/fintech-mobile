#!/usr/bin/env bash
# Generates localized Google Play notes from RN-es/RN-en Git trailers.
set -Eeuo pipefail
IFS=$'\n\t'

readonly release_tag_pattern='^v[0-9]+\.[0-9]+\.[0-9]+$'
repo_root="$(git rev-parse --show-toplevel)" || {
  printf 'Release-note generation must run inside a Git repository.\n' >&2
  exit 1
}
cd "$repo_root"

current_tag="${CM_TAG:-${1:-}}"
if [[ ! "$current_tag" =~ $release_tag_pattern ]]; then
  printf 'Tag %q is not an exact semantic release tag (v<major>.<minor>.<patch>).\n' "$current_tag" >&2
  exit 1
fi

shallow_repository="$(git rev-parse --is-shallow-repository)"
origin_url="$(git remote get-url origin 2>/dev/null || true)"
if [[ "$shallow_repository" == 'true' ]]; then
  if [[ -z "$origin_url" ]]; then
    printf 'Repository history is shallow and origin is unavailable; cannot generate complete release notes.\n' >&2
    exit 1
  fi
  if ! git fetch --quiet --unshallow --tags origin; then
    printf 'Repository history is shallow and could not be unshallowed from origin; cannot generate complete release notes.\n' >&2
    exit 1
  fi
  if [[ "$(git rev-parse --is-shallow-repository)" == 'true' ]]; then
    printf 'Repository history remains shallow after fetching origin; cannot generate complete release notes.\n' >&2
    exit 1
  fi
elif [[ -n "$origin_url" ]]; then
  git fetch --quiet --force --tags origin
fi

current_commit="$(git rev-parse --verify "refs/tags/$current_tag^{commit}")" || {
  printf 'Release tag %s is not available locally.\n' "$current_tag" >&2
  exit 1
}
head_commit="$(git rev-parse --verify 'HEAD^{commit}')"
if [[ "$current_commit" != "$head_commit" ]]; then
  printf 'Release tag %s does not point at HEAD.\n' "$current_tag" >&2
  exit 1
fi

previous_tag=''
previous_distance=''
while IFS= read -r candidate; do
  [[ "$candidate" =~ $release_tag_pattern ]] || continue

  candidate_commit="$(git rev-parse --verify "refs/tags/$candidate^{commit}")" || continue
  [[ "$candidate_commit" == "$current_commit" ]] && continue
  git merge-base --is-ancestor "$candidate_commit" "$current_commit" || continue

  distance="$(git rev-list --count "$candidate_commit..$current_commit")"
  if [[ -z "$previous_distance" || "$distance" -lt "$previous_distance" ]]; then
    previous_tag="$candidate"
    previous_distance="$distance"
  fi
done < <(LC_ALL=C git for-each-ref --format='%(refname:short)' refs/tags | LC_ALL=C sort)

if [[ -n "$previous_tag" ]]; then
  revision_range="$previous_tag..$current_tag"
else
  revision_range="$current_tag"
fi

tempdir="$(mktemp -d "${TMPDIR:-/tmp}/play-release-notes.XXXXXX")"
cleanup() {
  rm -rf -- "$tempdir"
}
trap cleanup EXIT

collect_trailers() {
  local trailer=$1
  local output=$2

  git log --reverse --date-order --format='%B' "$revision_range" |
    awk -v trailer="$trailer" '
      index($0, trailer) == 1 {
        note = substr($0, length(trailer) + 1)
        sub(/^[[:space:]]+/, "", note)
        if (note != "") print "- " note
      }
    ' > "$output"
}

spanish_notes="$tempdir/release_notes_es.txt"
english_notes="$tempdir/release_notes_en.txt"
collect_trailers 'RN-es:' "$spanish_notes"
collect_trailers 'RN-en:' "$english_notes"

missing=()
[[ -s "$spanish_notes" ]] || missing+=('RN-es:')
[[ -s "$english_notes" ]] || missing+=('RN-en:')
if ((${#missing[@]} > 0)); then
  printf 'Missing required release-note trailer(s): %s in range %s.\n' \
    "${missing[*]}" "$revision_range" >&2
  exit 1
fi

cp "$spanish_notes" release_notes_es-ES.txt
cp "$spanish_notes" release_notes_es-419.txt
cp "$english_notes" release_notes_en-US.txt

printf 'Generated Google Play release notes for %s from %s.\n' "$current_tag" "$revision_range"
