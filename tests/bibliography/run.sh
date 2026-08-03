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
  # If Biber rejected the `date` of every entry that has one, the fault is its
  # date parser, not this fixture's data: the years vanish and the ydnt sort
  # order silently comes out wrong (issue #211). Counting `date` fields rather
  # than entries keeps this correct if a `year`-only entry is added later. Biber
  # is a PAR-packed binary that unpacks its Perl runtime -- including the
  # DateTime modules only the `date` path uses -- into a per-user cache under
  # TMPDIR, which macOS purges periodically. An incomplete cache breaks `date`
  # while the legacy `year` field, which needs no DateTime, keeps working. Name
  # that here so the next reader does not re-derive it; the gate still fails.
  dated="$(grep -Ec '^[[:space:]]*date[[:space:]]*=' publications.bib || true)"
  rejected="$(grep -Eic "Invalid format .* of date field" "$base.blg" || true)"
  if [ "$rejected" -gt 0 ] && [ "$rejected" -eq "$dated" ]; then
    echo
    echo "  DIAGNOSIS: Biber rejected the 'date' field of all $dated entries."
    echo "  This is a local Biber install fault, not a fixture-data problem."
    echo "  The same fixture passes in CI on the pinned TeX Live container, so"
    echo "  it is this install rather than Biber in general. To repair it:"
    echo
    echo "    rm -rf \"\${TMPDIR:-/tmp}\"/par-*   # drop Biber's unpacked cache"
    echo "    biber --version                   # re-unpack, then re-run"
    echo
    echo "  If that does not help, see CONTRIBUTING.md (\"BibLaTeX/Biber"
    echo "  fixture\"). Do not switch the fixture to 'year=' and do not relax"
    echo "  this gate: either would hide a genuinely wrong bibliography."
  fi
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

# The bibliography's inter-entry gap must stay tied to the CV's calibrated list
# token instead of drifting back to a fixed length. The fixture raises its own
# package error on a mismatch, so a clean build is the assertion.
echo "== bibitemsep-token.tex (bibitemsep tracks CDossierRecordItemSepSkip) =="
if ! latexmk -lualatex -interaction=nonstopmode -halt-on-error \
    "bibitemsep-token.tex" > "bibitemsep-token.stdout" 2>&1; then
  echo "  \\bibitemsep does not track \\CDossierRecordItemSepSkip"
  echo "  (see bibitemsep-token.log)"
  exit 1
fi
echo "  bibitemsep tracks CDossierRecordItemSepSkip"
