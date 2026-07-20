#!/usr/bin/env bash
# run.sh — CareerDossierTeX layout-stress runner (Phase 1)
#
# Compiles each layout fixture with LuaLaTeX and asserts the page-level
# properties that a document class must keep under stress:
#
#   - it compiles with exit 0;
#   - it produces no overfull boxes (long URLs break; long headings wrap);
#   - the résumé emits no page number, while the academic CV emits a folio on
#     every page and a running header after page one;
#   - a fixture named *two-page* actually spans at least two pages.
#
# Final visual correctness (spacing, balance, typographic detail) remains a
# human review of the rendered PDF; this runner guards the properties a machine
# can check reliably without freezing an unsettled design.
#
# Requirements: lualatex, pdftotext (poppler) for the page-number check.
# Run from anywhere; the repository root is placed on TEXINPUTS.
set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../.." && pwd)"
cd "$here"
export TEXINPUTS="$root:${TEXINPUTS:-}"
fail=0

for tex in *.tex; do
  base="${tex%.tex}"
  echo "== $tex =="

  if ! lualatex -halt-on-error -interaction=nonstopmode "$tex" > "$base.stdout" 2>&1; then
    echo "  COMPILE FAILED (see $base.log)"; fail=1; continue
  fi
  if ! lualatex -halt-on-error -interaction=nonstopmode "$tex" >> "$base.stdout" 2>&1; then
    echo "  RERUN FAILED (see $base.log)"; fail=1; continue
  fi

  # No overfull boxes.
  overfull="$(grep -cE 'Overfull \\hbox' "$base.log" || true)"
  if [ "$overfull" -ne 0 ]; then
    echo "  OVERFULL BOXES: $overfull"
    grep -E 'Overfull \\hbox' "$base.log" | sed 's/^/    /' | head -5; fail=1
  else
    echo "  no overfull boxes"
  fi

  # Page count from the "Output written ... (N page[s])" line.
  pages="$(grep -oE 'Output written on .*\(([0-9]+) page' "$base.log" \
           | grep -oE '\(([0-9]+) page' | grep -oE '[0-9]+' | tail -1)"
  pages="${pages:-0}"
  echo "  pages: $pages"

  # The résumé's empty page style must print no folio. The CV instead requires
  # a visible `Page N of M` folio on every page and an identity-derived running
  # header from page two onwards. The folio carries the total, matching
  # careerdossier-letter: a bare `Page N` cannot tell a reader holding page two
  # whether the document ended. Check the extracted text rather than exact
  # page coordinates so the test guards behavior without freezing layout.
  if command -v pdftotext >/dev/null 2>&1; then
    case "$base" in
      cv-*)
        cv_fail=0
        for (( n = 1; n <= pages; n++ )); do
          page_text="$(pdftotext -enc UTF-8 -f "$n" -l "$n" "$base.pdf" - | sed '/^\f/d')"
          if ! printf '%s\n' "$page_text" | grep -Fqx "Page $n of $pages"; then
            echo "  MISSING CV FOLIO: Page $n of $pages"; cv_fail=1
          fi
          if [ "$n" -gt 1 ] && { ! printf '%s\n' "$page_text" | grep -Fq "Ada Lovelace" || ! printf '%s\n' "$page_text" | grep -Fq "Curriculum"; }; then
            echo "  MISSING CV RUNNING HEADER on page $n"; cv_fail=1
          fi
        done
        if [ "$cv_fail" -ne 0 ]; then
          fail=1
        else
          echo "  CV folios and running headers present"
        fi
        ;;
      letter-academic-*)
        letter_fail=0
        for (( n = 1; n <= pages; n++ )); do
          page_text="$(pdftotext -enc UTF-8 -f "$n" -l "$n" "$base.pdf" - | sed '/^\f/d')"
          if ! printf '%s\n' "$page_text" | grep -Fqx "Page $n of $pages"; then
            echo "  MISSING ACADEMIC-LETTER FOLIO: Page $n of $pages"; letter_fail=1
          fi
          if ! printf '%s\n' "$page_text" | grep -Fq "Ada Lovelace"; then
            echo "  MISSING ACADEMIC-LETTER FOOTER NAME on page $n"; letter_fail=1
          fi
        done
        if [ "$letter_fail" -ne 0 ]; then fail=1; else echo "  academic-letter footers present"; fi
        ;;
      *)
        folio=0
        for (( n = 1; n <= pages; n++ )); do
          last="$(pdftotext -enc UTF-8 -f "$n" -l "$n" "$base.pdf" - \
                  | sed '/^\f/d' | awk 'NF{ line = $0 } END{ print line }' \
                  | tr -d '[:space:]')"
          [ "$last" = "$n" ] && folio=1
        done
        if [ "$folio" -ne 0 ]; then
          echo "  UNEXPECTED page-number folio"; fail=1
        else
          echo "  no page-number folios"
        fi
        ;;
    esac
  else
    echo "  (pdftotext absent: skipped folio check)"
  fi

  case "$base" in
    *two-page*)
      if [ "$pages" -lt 2 ]; then
        echo "  EXPECTED at least two pages, got $pages"; fail=1
      else
        echo "  spans multiple pages as intended"
      fi
      ;;
  esac
done

echo; [ "$fail" -eq 0 ] && echo "ALL LAYOUT FIXTURES PASSED" || echo "LAYOUT FIXTURES FAILED"
exit "$fail"
