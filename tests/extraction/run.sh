#!/usr/bin/env bash
# run.sh — CareerDossierTeX extraction fixture runner (Phase 1)
#
# Compiles each *.tex fixture in this directory with LuaLaTeX and gates it on
# three checks:
#
#   1. Poppler (pdftotext) extraction vs. the committed *.expected.txt baseline.
#      Proves the visible text, its Unicode mapping, and its reading order agree.
#   2. No /ActualText in the PDF (issue #72). Poppler recovers interword spaces
#      from glyph geometry, so check 1 alone cannot see per-word /ActualText
#      spans — but PDFKit-class consumers concatenate them and merge words. This
#      check is the portable guard and runs everywhere, including Linux CI.
#   3. Apple PDFKit extraction vs. the committed *.pdfkit.txt baseline. The real
#      end-to-end consumer path behind Preview, Quick Look, Spotlight, Safari,
#      and macOS copy/paste. macOS only; skipped with a notice elsewhere.
#
# Checks 2 and 3 overlap deliberately: 2 catches the known root cause anywhere,
# 3 catches a merge arriving by some other route, on the platform that can see
# it. PDFKit and Poppler impose different line structure on multi-column layout,
# so each keeps its own baseline rather than sharing one.
#
# It also scans the LuaLaTeX log for warnings, treating a small, explicit
# allowlist of known-benign messages as acceptable and failing on anything else.
#
# Requirements: lualatex, pdftotext (poppler). PDFKit check additionally needs
# macOS + osascript. Run from anywhere.
# Regenerate baselines intentionally with:  ./run.sh --update
# On Linux, --update refreshes only the Poppler baselines; regenerate the PDFKit
# ones on macOS.
set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
cd "$here"
# Put the repository root on TEXINPUTS so fixtures that load the CareerDossierTeX
# classes and packages resolve them; standalone fixtures are unaffected.
root="$(cd "$here/../.." && pwd)"
export TEXINPUTS="$root:${TEXINPUTS:-}"
update=0; [ "${1:-}" = "--update" ] && update=1
fail=0

# Build uncompressed so /ActualText is greppable in the PDF without needing
# qpdf, mutool, or a Python zlib helper that CI images may not carry. LuaHBTeX
# exposes both compression controls directly; changing them does not affect
# rendered or extracted text.

# PDFKit is macOS-only. Probe once rather than per fixture.
pdfkit=0
if [ "$(uname -s)" = "Darwin" ] && command -v osascript > /dev/null 2>&1; then
  pdfkit=1
else
  echo "note: not macOS (or osascript missing) — skipping the PDFKit checks."
  echo "      The /ActualText guard still covers issue #72 on this platform."
  echo
fi

# Strip form feeds, then trailing blank lines. The trailing-blank trim uses awk,
# not a sed label/branch loop, because the BSD sed shipped on macOS parses
# `{$d;N;ba}` differently from GNU sed; awk behaves identically on both, so the
# accumulated suite runs locally and in CI.
normalize() {
  sed '/^\f/d' | awk '{ line[NR] = $0 }
                      END { last = NR
                            while (last > 0 && line[last] ~ /^[[:space:]]*$/) last--
                            for (i = 1; i <= last; i++) print line[i] }'
}

# Log lines that are allowed to appear. Keep this list short and justified.
#  - clig/hlig "not available": TeX Gyre Heros has no contextual/historic
#    ligature tables to disable; the common-ligature suppression still applies.
allow='not available for font|Ligatures=CommonOff|ContextualOff, DiscretionaryOff|rerun|Reading font info|geometry|hyperref'

for tex in *.tex; do
  base="${tex%.tex}"; exp="$base.expected.txt"; kexp="$base.pdfkit.txt"
  echo "== $tex =="
  if [ ! -f "$exp" ] && [ "$update" -eq 0 ]; then
    echo "  MISSING baseline $exp (run with --update to create)"; fail=1; continue
  fi

  lua_input="\\pdfvariable compresslevel=0 \\pdfvariable objcompresslevel=0 \\input{$tex}"
  lualatex -halt-on-error -interaction=nonstopmode -jobname="$base" \
    "$lua_input" > "$base.stdout" 2>&1 || {
    echo "  COMPILE FAILED (see $base.log)"; fail=1; continue; }
  # Resolve end-of-document labels such as the academic-letter total-page footer.
  lualatex -halt-on-error -interaction=nonstopmode -jobname="$base" \
    "$lua_input" >> "$base.stdout" 2>&1 || {
    echo "  RERUN FAILED (see $base.log)"; fail=1; continue; }

  got="$(pdftotext -enc UTF-8 "$base.pdf" - | normalize)"

  # The statement class derives PDF identity from the full page-one title, not
  # the abbreviated running title. Pin both fields on the focused statement
  # fixture; pdfinfo ships with the same Poppler dependency as pdftotext.
  case "$base" in
    statement-interest)
      expected_pdf_title="Statement of Interest – Ada Lovelace"
      pdf_title="$(pdfinfo "$base.pdf" | sed -n 's/^Title:[[:space:]]*//p')"
      pdf_author="$(pdfinfo "$base.pdf" | sed -n 's/^Author:[[:space:]]*//p')"
      if [ "$pdf_title" != "$expected_pdf_title" ]; then
        echo "  WRONG PDF TITLE: $pdf_title"; fail=1
      else
        echo "  PDF title uses the full statement title"
      fi
      if [ "$pdf_author" != "Ada Lovelace" ]; then
        echo "  WRONG PDF AUTHOR: $pdf_author"; fail=1
      else
        echo "  PDF author uses the profile name"
      fi
      ;;
    statement-*)
      pdf_title="$(pdfinfo "$base.pdf" | sed -n 's/^Title:[[:space:]]*//p')"
      pdf_author="$(pdfinfo "$base.pdf" | sed -n 's/^Author:[[:space:]]*//p')"
      if [ "$pdf_title" != "Teaching Statement – Ada Lovelace" ]; then
        echo "  WRONG PDF TITLE: $pdf_title"; fail=1
      else
        echo "  PDF title uses the full statement title"
      fi
      if [ "$pdf_author" != "Ada Lovelace" ]; then
        echo "  WRONG PDF AUTHOR: $pdf_author"; fail=1
      else
        echo "  PDF author uses the profile name"
      fi
      ;;
  esac

  if [ "$update" -eq 1 ]; then
    printf '%s\n' "$got" > "$exp"; echo "  baseline updated: $exp"
    if [ "$pdfkit" -eq 1 ]; then
      osascript -l JavaScript "$here/pdfkit-extract.js" "$here/$base.pdf" \
        | normalize > "$kexp"
      echo "  baseline updated: $kexp"
    fi
    continue
  fi

  if ! diff -u "$exp" <(printf '%s\n' "$got") > "$base.diff"; then
    echo "  EXTRACTION MISMATCH:"; sed 's/^/    /' "$base.diff"; fail=1
  else
    echo "  extraction OK (poppler)"
  fi

  # Issue #72: per-word /ActualText spans carry no interword space, so any
  # consumer that trusts them over glyph geometry merges adjacent words. The
  # package must not emit them at all.
  # -a: the PDF is uncompressed but still binary-ish, and grep without it
  # collapses every hit into a single "Binary file matches" line.
  if grep -qa '/ActualText' "$base.pdf"; then
    n="$(grep -oa '/ActualText' "$base.pdf" | wc -l | tr -d ' ')"
    echo "  /ActualText PRESENT ($n spans) — see issue #72."
    echo "    PDFKit-class consumers (Preview, Spotlight, Safari, copy/paste)"
    echo "    will merge adjacent words. Do not re-enable"
    echo "    engine-specific ActualText generation in careerdossier-typography.sty."
    fail=1
  else
    echo "  no /ActualText spans"
  fi

  if [ "$pdfkit" -eq 1 ]; then
    if [ ! -f "$kexp" ]; then
      echo "  MISSING baseline $kexp (run with --update on macOS to create)"; fail=1
    else
      kgot="$(osascript -l JavaScript "$here/pdfkit-extract.js" "$here/$base.pdf" \
              | normalize)"
      if ! diff -u "$kexp" <(printf '%s\n' "$kgot") > "$base.pdfkit.diff"; then
        echo "  PDFKIT EXTRACTION MISMATCH:"; sed 's/^/    /' "$base.pdfkit.diff"
        fail=1
      else
        echo "  extraction OK (pdfkit)"
      fi
    fi
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
