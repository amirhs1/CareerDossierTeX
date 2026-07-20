#!/usr/bin/env bash
# Build the focused Biber fixture, compare its extracted text, and reject Biber
# warnings/errors. The baseline pins ydnt ordering and DOI -> e-print -> URL
# precedence without treating the user-facing example as the test assertion.
set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../.." && pwd)"
cd "$here"
export TEXINPUTS="$root:${TEXINPUTS:-}"

base="cv-bibliography"
expected="$base.expected.txt"
update=0
[ "${1:-}" = "--update" ] && update=1

echo "== $base.tex (latexmk + Biber) =="
if ! latexmk -lualatex -interaction=nonstopmode -halt-on-error "$base.tex" > "$base.stdout" 2>&1; then
  echo "  BUILD FAILED (see $base.log and $base.blg)"
  exit 1
fi

if [ ! -f "$base.blg" ]; then
  echo "  MISSING Biber log $base.blg"
  exit 1
fi
if grep -Eiq '(^| - )(WARN|ERROR) -' "$base.blg"; then
  echo "  BIBER WARNINGS/ERRORS:"
  grep -Ei '(^| - )(WARN|ERROR) -' "$base.blg" | sed 's/^/    /'
  exit 1
fi
unexpected="$(grep -iE 'Warning:|Missing character|Font shape.*undefined|substituting|Overfull' \
  "$base.log" || true)"
if [ -n "$unexpected" ]; then
  echo "  UNEXPECTED LATEX LOG LINES:"
  printf '%s\n' "$unexpected" | sed 's/^/    /'
  exit 1
fi

got="$(pdftotext -enc UTF-8 "$base.pdf" - | sed '/^\f/d' \
  | awk '{ line[NR] = $0 }
         END { last = NR
               while (last > 0 && line[last] ~ /^[[:space:]]*$/) last--
               for (i = 1; i <= last; i++) print line[i] }')"

if [ "$update" -eq 1 ]; then
  printf '%s\n' "$got" > "$expected"
  echo "  baseline updated: $expected"
elif [ ! -f "$expected" ]; then
  echo "  MISSING baseline $expected (run with --update to create)"
  exit 1
elif ! diff -u "$expected" <(printf '%s\n' "$got") > "$base.diff"; then
  echo "  BIBLIOGRAPHY EXTRACTION MISMATCH:"
  sed 's/^/    /' "$base.diff"
  exit 1
else
  echo "  ordering and identifier precedence OK"
fi

echo "  Biber completed without warnings/errors"
