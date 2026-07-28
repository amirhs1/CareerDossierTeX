#!/usr/bin/env bash
# run.sh — CareerDossierTeX layout-stress runner (Phase 1)
#
# Compiles each layout fixture with LuaLaTeX and asserts the page-level
# properties that a document class must keep under stress:
#
#   - it compiles with exit 0;
#   - it produces no overfull boxes (long URLs break; long headings wrap);
#   - every one-page document suppresses page furniture, while every multi-page
#     document emits a folio throughout and a running header after page one;
#   - a fixture named *two-page* actually spans at least two pages.
#
# Final visual correctness (spacing, balance, typographic detail) remains a
# human review of the rendered PDF; this runner guards the properties a machine
# can check reliably without freezing an unsettled design.
#
# Requirements: lualatex, pdftotext (poppler) for the page-number check, and
# pdfinfo (poppler) for A4 media-box verification.
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

  # Every *-a4-* wrapper must produce an actual ISO A4 media box. This catches
  # a class accepting the public option but silently retaining Letter paper.
  case "$base" in
    *-a4-*)
      if ! command -v pdfinfo >/dev/null 2>&1; then
        echo "  pdfinfo absent: cannot verify A4 media box"; fail=1
      elif ! pdfinfo -f 1 -l 1 "$base.pdf" | grep -Eq '^Page( +[0-9]+)? size:.*\(A4\)$'; then
        echo "  WRONG PAPER SIZE: expected A4"
        pdfinfo -f 1 -l 1 "$base.pdf" | grep -E '^Page( +[0-9]+)? size:' | sed 's/^/    /'
        fail=1
      else
        echo "  A4 media box confirmed"
      fi
      ;;
    *)
      if ! command -v pdfinfo >/dev/null 2>&1; then
        echo "  pdfinfo absent: cannot verify default Letter media box"; fail=1
      elif ! pdfinfo -f 1 -l 1 "$base.pdf" | grep -Eq '^Page( +[0-9]+)? size:.*\(letter\)$'; then
        echo "  WRONG DEFAULT PAPER SIZE: expected Letter"
        pdfinfo -f 1 -l 1 "$base.pdf" | grep -E '^Page( +[0-9]+)? size:' | sed 's/^/    /'
        fail=1
      else
        echo "  default Letter media box confirmed"
      fi
      ;;
  esac

  # Shared page furniture is suppressed entirely for a one-page document. A
  # multi-page document carries `Page N of M` throughout and an
  # identity-derived running header from page two onwards. Check extracted text
  # rather than exact coordinates so the test guards behavior without freezing
  # layout.
  if command -v pdftotext >/dev/null 2>&1; then
    furniture_label=""
    case "$base" in
      resume-*)           furniture_label="Résumé" ;;
      cv-*)               furniture_label="Curriculum Vitae" ;;
      letter-*)           furniture_label="Cover Letter" ;;
      statement-interest-long-fields-two-page)
        furniture_label="Statement of Interest"
        ;;
      statement-*)        furniture_label="Computational Reliability" ;;
    esac

    furniture_fail=0
    page_one_label_count=0
    if [ "$base" = "statement-interest-long-fields-two-page" ]; then
      # The display title and running title are intentionally identical. Page
      # one must contain the display title once, not a second copy in a header.
      page_one_label_count=1
    fi
    for (( n = 1; n <= pages; n++ )); do
      page_text="$(pdftotext -enc UTF-8 -f "$n" -l "$n" "$base.pdf" - | sed '/^\f/d')"
      if [ "$pages" -eq 1 ]; then
        if printf '%s\n' "$page_text" | grep -Fq "Page 1 of 1"; then
          echo "  UNEXPECTED SINGLE-PAGE FOLIO"; furniture_fail=1
        fi
      elif ! printf '%s\n' "$page_text" | grep -Fq "Page $n of $pages"; then
        echo "  MISSING FOLIO: Page $n of $pages"; furniture_fail=1
      fi

      if [ "$pages" -gt 1 ] && [ "$n" -gt 1 ] \
          && ! printf '%s\n' "$page_text" | grep -Fq "$furniture_label"; then
        echo "  MISSING RUNNING HEADER on page $n: $furniture_label"
        furniture_fail=1
      fi
      if [ "$pages" -gt 1 ] && [ "$n" -eq 1 ]; then
        label_count="$(printf '%s\n' "$page_text" | grep -Fc "$furniture_label" || true)"
        if [ "$label_count" -ne "$page_one_label_count" ]; then
          echo "  UNEXPECTED PAGE-ONE RUNNING LABEL count: $label_count"
          furniture_fail=1
        fi
      fi
    done
    if [ "$furniture_fail" -ne 0 ]; then
      fail=1
    elif [ "$pages" -eq 1 ]; then
      echo "  single-page furniture suppressed"
    else
      echo "  multi-page folios and running headers present"
    fi
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
