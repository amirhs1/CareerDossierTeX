#!/usr/bin/env bash
# run.sh — CareerDossierTeX extraction fixture runner (Phase 1)
#
# Compiles each *.tex fixture in this directory with XeLaTeX, extracts the text
# layer with pdftotext, and diffs it against the committed *.expected.txt
# baseline. The diff is the pass/fail gate: it proves the visible text, its
# Unicode mapping, and its reading order agree.
#
# It also scans the XeLaTeX log for warnings, treating a small, explicit
# allowlist of known-benign messages as acceptable and failing on anything else.
#
# Requirements: xelatex, pdftotext (poppler). Run from anywhere.
# Regenerate a baseline intentionally with:  ./run.sh --update
set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
cd "$here"
# Put the repository root on TEXINPUTS so fixtures that load the CareerDossierTeX
# classes and packages resolve them; standalone fixtures are unaffected.
root="$(cd "$here/../.." && pwd)"
export TEXINPUTS="$root:${TEXINPUTS:-}"
update=0; [ "${1:-}" = "--update" ] && update=1
fail=0

# Log lines that are allowed to appear. Keep this list short and justified.
#  - clig/hlig "not available": TeX Gyre Heros has no contextual/historic
#    ligature tables to disable; the common-ligature suppression still applies.
allow='not available for font|Ligatures=CommonOff|ContextualOff, DiscretionaryOff|rerun|Reading font info|geometry|hyperref'

for tex in *.tex; do
  base="${tex%.tex}"; exp="$base.expected.txt"
  echo "== $tex =="
  if [ ! -f "$exp" ] && [ "$update" -eq 0 ]; then
    echo "  MISSING baseline $exp (run with --update to create)"; fail=1; continue
  fi

  xelatex -halt-on-error -interaction=nonstopmode "$tex" > "$base.log" 2>&1 || {
    echo "  COMPILE FAILED (see $base.log)"; fail=1; continue; }
  # Resolve end-of-document labels such as the academic-letter total-page footer.
  xelatex -halt-on-error -interaction=nonstopmode "$tex" >> "$base.log" 2>&1 || {
    echo "  RERUN FAILED (see $base.log)"; fail=1; continue; }

  # Normalize: drop form-feeds and trailing blank lines, keep meaningful text.
  # The trailing-blank trim uses awk, not a sed label/branch loop, because the
  # BSD sed shipped on macOS parses `{$d;N;ba}` differently from GNU sed; awk
  # behaves identically on both, so the accumulated suite runs locally and in CI.
  got="$(pdftotext -enc UTF-8 "$base.pdf" - | sed '/^\f/d' \
        | awk '{ line[NR] = $0 }
               END { last = NR
                     while (last > 0 && line[last] ~ /^[[:space:]]*$/) last--
                     for (i = 1; i <= last; i++) print line[i] }')"

  if [ "$update" -eq 1 ]; then
    printf '%s\n' "$got" > "$exp"; echo "  baseline updated: $exp"; continue
  fi

  if ! diff -u "$exp" <(printf '%s\n' "$got") > "$base.diff"; then
    echo "  EXTRACTION MISMATCH:"; sed 's/^/    /' "$base.diff"; fail=1
  else
    echo "  extraction OK"
  fi

  # Warning triage: any Warning/Missing/substitution not on the allowlist fails.
  unexpected="$(grep -iE 'Warning:|Missing character|Font shape.*undefined|substituting' "$base.log" \
                | grep -viE "$allow" || true)"
  if [ -n "$unexpected" ]; then
    echo "  UNEXPECTED LOG LINES:"; printf '%s\n' "$unexpected" | sed 's/^/    /'
    fail=1
  else
    echo "  log clean (allowlisted warnings only)"
  fi
done

echo; [ "$fail" -eq 0 ] && echo "ALL EXTRACTION FIXTURES PASSED" || echo "EXTRACTION FIXTURES FAILED"
exit "$fail"
