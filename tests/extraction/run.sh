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
#
# Usage:
#   ./run.sh                    every fixture — the full suite, and what CI runs
#   ./run.sh <pattern>          only the fixtures matching <pattern>
#   ./run.sh --list [<pattern>] print the selection and compile nothing
#   ./run.sh --update [<pat>]   regenerate the selected baselines
#
# or, through the Makefile:  make extract-test FIXTURE=<pattern>
set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
cd "$here" || exit 1
# Put the repository root on TEXINPUTS so fixtures that load the CareerDossierTeX
# classes and packages resolve them; standalone fixtures are unaffected.
root="$(cd "$here/../.." && pwd)"
export TEXINPUTS="$root:${TEXINPUTS:-}"

# Extracted-text guards that answer "could not check" apart from "absent"
# (issue #398).
# shellcheck source=tests/lib/text.sh
. "$root/tests/lib/text.sh"

# Fixture selection (issue #359). The pattern is a shell glob matched anywhere
# in the basename, so `resume` behaves as a substring search and `statement-*`
# anchors at the start; it is left unquoted in the `case` below for that reason.
# With no pattern every fixture runs, which is what CI and `make check` invoke.
#
# A pattern selecting nothing exits nonzero rather than reporting a clean run:
# every assertion here is made per fixture, so a run with no fixtures passes all
# of them and looks exactly like a suite that checked something.
#
# `--update` composes with a pattern, which is the safer default for a baseline
# regeneration — it rewrites only the baselines the change was meant to move.
fixture_filter=""
list_only=0
update=0
for arg in "$@"; do
  case "$arg" in
    --update) update=1 ;;
    --list)   list_only=1 ;;
    -*)       echo "unknown option: $arg" >&2; exit 2 ;;
    *)        fixture_filter="$arg" ;;
  esac
done

fixtures=()
total=0
for tex in *.tex; do
  total=$(( total + 1 ))
  if [ -z "$fixture_filter" ]; then
    fixtures+=("$tex")
  else
    case "${tex%.tex}" in
      *$fixture_filter*) fixtures+=("$tex") ;;
    esac
  fi
done

if [ "${#fixtures[@]}" -eq 0 ]; then
  echo "NO FIXTURE MATCHES '$fixture_filter' (of $total in $here)."
  echo "  ./run.sh --list  prints every available fixture name."
  exit 1
fi

if [ "$list_only" -eq 1 ]; then
  for tex in "${fixtures[@]}"; do echo "${tex%.tex}"; done
  exit 0
fi

# Appended to the closing verdict so a filtered run can never be read as a full
# one. Empty for a full run, which keeps that line byte-identical to before.
scope_note=""
if [ -n "$fixture_filter" ]; then
  scope_note=" (filter '$fixture_filter': ${#fixtures[@]} of $total fixtures — NOT a full run)"
  echo "filter '$fixture_filter': ${#fixtures[@]} of $total fixtures selected"
  echo
fi

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

# Strip form-feed bytes without discarding text that follows one on the same
# line, then trim trailing blank lines. `tr` handles the byte identically on
# macOS and Linux; BSD and GNU sed disagree on whether `\f` is a form-feed
# escape. The trailing-blank trim uses awk, not a sed label/branch loop, because
# the BSD sed shipped on macOS parses `{$d;N;ba}` differently from GNU sed.
normalize() {
  tr -d '\014' | awk '{ line[NR] = $0 }
                      END { last = NR
                            while (last > 0 && line[last] ~ /^[[:space:]]*$/) last--
                            for (i = 1; i <= last; i++) print line[i] }'
}

# Compare captured text against a committed baseline, writing the observed text
# to <slot>.got and the difference to <slot>.diff. Returns diff's own status.
#
# The scratch file is load-bearing rather than tidy. This ran as
# `diff -u "$exp" <(printf '%s\n' "$got")` until issue #392, which fails under a
# restricted sandbox with
#
#   diff: /dev/fd/63: Operation not permitted
#
# because re-opening a pipe file descriptor is denied there. The denial lands on
# diff's *input*, so diff exits nonzero having compared nothing and the runner
# reported EXTRACTION MISMATCH above an empty .diff — infrastructure wearing a
# fixture defect's clothes, on a suite whose fixtures had not changed.
# tests/check-parallel.sh already avoids process substitution for this reason
# and is the in-repo precedent.
compare_to_baseline() { # <baseline> <observed text> <slot>
  printf '%s\n' "$2" > "$3.got"
  diff -u "$1" "$3.got" > "$3.diff"
}

# Log lines that are allowed to appear. Keep this list short and justified.
#  - clig/hlig "not available": TeX Gyre Heros has no contextual/historic
#    ligature tables to disable; the common-ligature suppression still applies.
allow='not available for font|Ligatures=CommonOff|ContextualOff, DiscretionaryOff|rerun|Reading font info|geometry|hyperref'

for tex in "${fixtures[@]}"; do
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

  if [ "$base" = "resume-contact-wrap" ]; then
    contact_text="$(text_extract "$base.pdf" -layout | normalize)"
    text_matches "$contact_text" '^[[:space:]]*\||\|[[:space:]]*$'; state=$?
    if [ "$state" -eq 0 ]; then
      echo "  ORPHAN CONTACT SEPARATOR in extracted visual line"; fail=1
    elif [ "$state" -ne 1 ]; then
      echo "  UNCHECKABLE CONTACT SEPARATORS: no -layout text for $base"; fail=1
    else
      echo "  wrapped contact lines have no orphan separators"
    fi
    contact_item_fail=0
    while IFS= read -r item; do
      text_contains "$contact_text" "$item"; state=$?
      if [ "$state" -eq 1 ]; then
        echo "  SPLIT CONTACT ITEM: $item"; fail=1; contact_item_fail=1
      elif [ "$state" -ne 0 ]; then
        echo "  UNCHECKABLE CONTACT ITEM: $item"; fail=1; contact_item_fail=1
      fi
    done <<'EOF'
alexandria.montgomery.fitzgerald@a-very-long-department.example.org
+1 416 555 0142
Greater Toronto Regional Office, Ontario, Canada
example.org/alexandria-montgomery-fitzgerald/portfolio
linkedin.com/in/alexandria-montgomery-fitzgerald
github.com/alexandria-montgomery-fitzgerald
scholar.google.com/citations?user=AlexandriaMontgomery
ORCID: 0000-0002-1825-0097
EOF
    if [ "$contact_item_fail" -eq 0 ]; then
      echo "  every contact item remains on one visual line"
    fi
  fi

  # The statement class derives PDF identity from the full page-one title, not
  # the abbreviated running title. Pin both fields on the focused statement
  # fixture; pdfinfo ships with the same Poppler dependency as pdftotext.
  case "$base" in
    statement-diversity-title)
      expected_pdf_title="Statement of Contributions to Equity, Diversity, Inclusion, and Accessibility – Ada Lovelace"
      pdf_title="$(pdfinfo "$base.pdf" | sed -n 's/^Title:[[:space:]]*//p')"
      pdf_author="$(pdfinfo "$base.pdf" | sed -n 's/^Author:[[:space:]]*//p')"
      if [ "$pdf_title" != "$expected_pdf_title" ]; then
        echo "  WRONG PDF TITLE: $pdf_title"; fail=1
      else
        echo "  PDF title uses the full diversity-statement title"
      fi
      if [ "$pdf_author" != "Ada Lovelace" ]; then
        echo "  WRONG PDF AUTHOR: $pdf_author"; fail=1
      else
        echo "  PDF author uses the profile name"
      fi
      ;;
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

  if ! compare_to_baseline "$exp" "$got" "$base"; then
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
      if ! compare_to_baseline "$kexp" "$kgot" "$base.pdfkit"; then
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

# Cross-medium identity (issue #278).
#
# The two fixtures below share one body include and differ in one class option,
# `medium'. Under `screen' a rule is drawn beneath author-written \href anchor
# text; under `print' nothing is. The rule is ink, and ink is all it may be — an
# ATS, a recruiter's copy-paste, and a screen reader must read the identical
# document either way.
#
# Each fixture is already gated against its own baseline above. This compares
# the two baselines to each other, so the property survives the one thing a
# per-fixture check cannot catch: an intended-looking change regenerated into
# both files at once. The names are listed rather than derived, because the
# claim is about this specific pair.
#
# Under a fixture filter (issue #359) it runs whenever *either* member is
# selected, not only when both are. It compares committed baselines rather than
# fresh output, so one member is enough to make the comparison meaningful — and
# selecting exactly one is the case that most needs it: `--update` on a single
# member rewrites that baseline and leaves its sibling's alone, which is
# precisely how the pair would drift apart.
medium_pair_selected=0
for member in resume-link-decoration-print resume-link-decoration-screen; do
  case " ${fixtures[*]} " in
    *" $member.tex "*) medium_pair_selected=1 ;;
  esac
done

echo
echo "== cross-medium identity =="
if [ "$medium_pair_selected" -eq 0 ]; then
  echo "  skipped: filter '$fixture_filter' selected neither"
  echo "    resume-link-decoration-print nor resume-link-decoration-screen"
fi
for extractor in expected pdfkit; do
  [ "$medium_pair_selected" -eq 1 ] || continue
  a="$here/resume-link-decoration-print.$extractor.txt"
  b="$here/resume-link-decoration-screen.$extractor.txt"
  if [ ! -f "$a" ] || [ ! -f "$b" ]; then
    if [ "$extractor" = "pdfkit" ] && [ "$pdfkit" -eq 0 ]; then
      echo "  skipped ($extractor baselines are macOS-only)"
    else
      echo "  MISSING one of the $extractor baselines for the medium pair"; fail=1
    fi
    continue
  fi
  if diff -u "$a" "$b" > "$here/medium-pair.$extractor.diff"; then
    echo "  print and screen extract identically ($extractor)"
    rm -f "$here/medium-pair.$extractor.diff"
  else
    echo "  MEDIUM PAIR MISMATCH ($extractor): the screen decoration reached the text layer"
    sed 's/^/    /' "$here/medium-pair.$extractor.diff"
    fail=1
  fi
done

echo
[ "$fail" -eq 0 ] && echo "ALL EXTRACTION FIXTURES PASSED$scope_note" \
                  || echo "EXTRACTION FIXTURES FAILED$scope_note"
exit "$fail"
