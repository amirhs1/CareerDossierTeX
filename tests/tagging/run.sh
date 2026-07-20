#!/usr/bin/env bash
# run.sh -- opt-in tagged-PDF structure checks for issue #28.
#
# This suite deliberately stops short of PDF/UA validation and screen-reader
# review; those release gates belong to issue #77. It verifies the behavior
# introduced here: semantic headings/lists/paragraphs/links, artifact-marked
# decoration and pagination, logical extraction order, an absent structure tree
# when tagging is not requested, and equivalent tagged/untagged word geometry.
set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../.." && pwd)"
work="${TMPDIR:-/tmp}/careerdossier-tagging-$$"
trap 'rm -rf "$work"' EXIT
mkdir -p "$work"

export TEXINPUTS="$here:$root:${TEXINPUTS:-}"
fail=0

for command in lualatex pdftotext; do
  if ! command -v "$command" >/dev/null 2>&1; then
    echo "MISSING required command: $command"
    exit 1
  fi
done

normalize() {
  tr -d '\f' | awk '{ line[NR] = $0 }
                      END { last = NR
                            while (last > 0 && line[last] ~ /^[[:space:]]*$/) last--
                            for (i = 1; i <= last; i++) print line[i] }'
}

record_failure() {
  echo "  FAIL: $1"
  fail=1
}

compile_fixture() {
  local source="$1" job="$2"
  local pass unexpected
  for pass in 1 2; do
    if ! lualatex -output-directory="$work" -jobname="$job" \
        -halt-on-error -interaction=nonstopmode "$here/$source" \
        >"$work/$job.stdout" 2>&1; then
      record_failure "$source did not compile on pass $pass (see $work/$job.stdout)"
      return 1
    fi
  done

  unexpected="$(grep -iE \
    'Warning:|Missing character|Font shape.*undefined|substituting|Undefined control sequence|Overfull' \
    "$work/$job.log" | grep -viE 'Neither unicode-math nor lua-unicode-math' || true)"
  if [ -n "$unexpected" ]; then
    record_failure "$source produced unexpected log diagnostics"
    printf '%s\n' "$unexpected" | sed 's/^/    /'
    return 1
  fi
}

check_structure() {
  local base="$1"
  local pdf="$work/$base.pdf"

  grep -qa 'StructTreeRoot' "$pdf" || record_failure "$base has no structure tree"
  grep -qa '/S /Link' "$pdf" || record_failure "$base has no semantic Link"
  grep -qa '/S /text' "$pdf" || record_failure "$base has no semantic paragraph text"
  grep -qa '/Artifact<</Type /Layout>> BDC' "$pdf" \
    || record_failure "$base has no Layout artifact"

  if [ "$base" = resume ] || [ "$base" = cv ]; then
    grep -qa '/S /section' "$pdf" || record_failure "$base has no semantic section heading"
    grep -Fqa '/section [/H1' "$pdf" || record_failure "$base section is not role-mapped to H1"
    grep -qa '/S /itemize' "$pdf" || record_failure "$base has no semantic list"
    grep -qa '/S /item ' "$pdf" || record_failure "$base has no semantic list item"
    grep -qa '/S /itembody' "$pdf" || record_failure "$base has no semantic list-item body"
  fi

  if [ "$base" = cv ]; then
    grep -qa '/Artifact BMC' "$pdf" \
      || record_failure "cv running header/folio are not artifacts"
  fi

  if [ "$base" = academic-letter ]; then
    grep -qa '/Artifact BMC' "$pdf" \
      || record_failure "academic-letter repeated footer is not an artifact"
  fi
}

check_extraction() {
  local base="$1" got="$work/$base.txt" expected="$here/$base.expected.txt"
  pdftotext -enc UTF-8 "$work/$base.pdf" - | normalize >"$got"
  if ! diff -u "$expected" "$got" >"$work/$base.diff"; then
    record_failure "$base extraction differs from $base.expected.txt"
    sed 's/^/    /' "$work/$base.diff"
  fi
}

check_untagged() {
  local base="$1"
  if grep -qa StructTreeRoot "$work/$base-untagged.pdf"; then
    record_failure "$base-untagged unexpectedly contains a structure tree"
  fi
}

check_visual_equivalence() {
  local base="$1" tagged="$work/$base.bbox" plain="$work/$base-untagged.bbox"
  # Compare every rendered word and its bounding box to one decimal point.
  # This catches material layout movement while tolerating sub-tenth-point
  # placement noise introduced by zero-width tagging whatsits.
  pdftotext -bbox "$work/$base.pdf" - \
    | grep '<word ' | sed -E 's/([0-9]+\.[0-9])[0-9]+"/\1"/g' >"$tagged"
  pdftotext -bbox "$work/$base-untagged.pdf" - \
    | grep '<word ' | sed -E 's/([0-9]+\.[0-9])[0-9]+"/\1"/g' >"$plain"
  if ! diff -u "$plain" "$tagged" >"$work/$base-layout.diff"; then
    record_failure "$base tagged/untagged word geometry differs"
    sed 's/^/    /' "$work/$base-layout.diff"
  fi
}

for base in resume cv letter academic-letter; do
  echo "== $base =="
  compile_fixture "$base.tex" "$base" || continue
  compile_fixture "$base-untagged.tex" "$base-untagged" || continue
  check_structure "$base"
  check_extraction "$base"
  check_untagged "$base"
  check_visual_equivalence "$base"
done

echo
if [ "$fail" -eq 0 ]; then
  echo "ALL TAGGING FIXTURES PASSED"
else
  echo "TAGGING FIXTURES FAILED"
fi
exit "$fail"
