#!/usr/bin/env bash
# run.sh — CareerDossierTeX copy-paste integrity runner (issue #294)
#
# A URL or an e-mail address must survive copy-and-paste out of a generated PDF
# as one unbroken token. That is a typesetting property, not a text one: Poppler
# starts a new word wherever an intra-word gap exceeds 0.1 em, so a URL whose
# breakpoints were stretched by a justified line extracts as
# `https : / / example . invalid /' while the rendered page looks untouched.
#
# Each fixture declares the tokens that must stay atomic in its own header:
#
#   % LINKTOKEN: <the exact visible text that must not split>
#   % LINKEXPECT: split          (optional; default `intact')
#
# `LINKEXPECT: split` marks a negative control — a fixture built to break the
# property on purpose, which must be reported as split. It is what keeps the
# rest of the suite from passing vacuously.
#
# The decision is made from `pdftotext -bbox` coordinates by link-token-check.awk,
# which is where the wrap-versus-split distinction lives; see its header for why
# extracted text cannot make that call.
#
# Coverage, one fixture per site that renders a link: the résumé contact line,
# the CV contact line and its manual publication list, both letter families, and
# the BibLaTeX bibliography.
#
# Requirements: lualatex and pdftotext (Poppler) for every fixture; latexmk and
# Biber additionally for the two `*-bibliography-*` fixtures, which are the ones
# that exercise the only site with stretchable URL glue. When Biber is missing
# those two are skipped with a notice and the runner says so in its summary — a
# pass without them is not a pass of the negative control.
# Run from anywhere; the repository root is placed on TEXINPUTS.
set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../.." && pwd)"
cd "$here"
export TEXINPUTS="$root:${TEXINPUTS:-}"
fail=0
skipped=""

have_biber=1
if ! command -v biber > /dev/null 2>&1 || ! command -v latexmk > /dev/null 2>&1; then
  have_biber=0
fi
if ! command -v pdftotext > /dev/null 2>&1; then
  echo "pdftotext (Poppler) is required: this suite decides split-versus-wrap"
  echo "from word bounding boxes and has nothing to assert without it."
  exit 1
fi

for tex in *.tex; do
  base="${tex%.tex}"
  echo "== $tex =="

  case "$base" in
    *bibliography*)
      if [ "$have_biber" -eq 0 ]; then
        echo "  SKIPPED: needs latexmk and Biber"
        skipped="$skipped $base"
        continue
      fi
      if ! latexmk -lualatex -interaction=nonstopmode -halt-on-error "$tex" \
           > "$base.stdout" 2>&1; then
        echo "  BUILD FAILED (see $base.log and $base.blg)"; fail=1; continue
      fi
      ;;
    *)
      # Two passes: the letter families resolve their total-page footer from
      # the .aux, and a first-pass PDF can carry a stale line breaking.
      if ! lualatex -halt-on-error -interaction=nonstopmode "$tex" \
           > "$base.stdout" 2>&1; then
        echo "  COMPILE FAILED (see $base.log)"; fail=1; continue
      fi
      if ! lualatex -halt-on-error -interaction=nonstopmode "$tex" \
           >> "$base.stdout" 2>&1; then
        echo "  RERUN FAILED (see $base.log)"; fail=1; continue
      fi
      ;;
  esac

  # An overfull line is the other way a link can misbehave under a hostile
  # measure, and it would otherwise hide here: with no stretch available TeX
  # sets the line long rather than spreading the URL. The negative control is
  # exempt — it exists to be badly set.
  expect="$(sed -n 's/^% LINKEXPECT:[[:space:]]*//p' "$tex" | head -1)"
  expect="${expect:-intact}"
  if [ "$expect" = "intact" ]; then
    overfull="$(grep -cE 'Overfull \\hbox' "$base.log" || true)"
    if [ "$overfull" -ne 0 ]; then
      echo "  OVERFULL BOXES: $overfull"
      grep -E 'Overfull \\hbox' "$base.log" | sed 's/^/    /' | head -5
      fail=1
    fi
  fi

  # The declared tokens travel to the checker in a file rather than on the
  # command line, so a token containing a shell metacharacter, a quote, or an
  # `=' cannot be mangled on the way.
  sed -n 's/^% LINKTOKEN:[[:space:]]*//p' "$tex" > "$base.tokens"
  if [ ! -s "$base.tokens" ]; then
    echo "  NO % LINKTOKEN: DIRECTIVES — the fixture asserts nothing"; fail=1; continue
  fi

  findings="$(pdftotext -bbox "$base.pdf" - \
    | awk -v tokfile="$base.tokens" -f "$here/link-token-check.awk")"
  printf '%s\n' "$findings" | sed 's/^/    /'

  # Here-strings, not `printf | grep -q`: under `pipefail` an early-exiting
  # grep leaves the producer killed by SIGPIPE, and the pipeline then reports
  # failure precisely when the pattern *did* match.
  missing=0; split_found=0
  grep -q '^MISSING' <<< "$findings" && missing=1
  grep -q '^SPLIT'   <<< "$findings" && split_found=1
  if grep -q '^ERROR' <<< "$findings"; then echo "  CHECKER ERROR"; fail=1; fi

  if [ "$missing" -eq 1 ]; then
    # Not a copy-paste defect but a broken assertion: the fixture stopped
    # rendering a link it claims to cover, so the token check ran on nothing.
    echo "  DECLARED TOKEN NOT PRESENT IN THE PDF (see MISSING above)"
    fail=1
  fi

  if [ "$expect" = "split" ]; then
    if [ "$split_found" -eq 1 ]; then
      echo "  negative control fired: the raised muskip splits the URL, as it must"
    else
      echo "  NEGATIVE CONTROL DID NOT FIRE: this fixture spreads a URL on purpose,"
      echo "    so the checker reporting it intact means the check is not looking"
      echo "    where it should, or can no longer see the defect. Do not relax it."
      fail=1
    fi
  elif [ "$split_found" -eq 1 ]; then
    echo "  SPLIT TOKEN: a URL or e-mail address is set as several words on one"
    echo "    baseline, so copy-and-paste yields embedded spaces. See the SPLIT"
    echo "    lines above for the pieces."
    fail=1
  elif [ "$missing" -eq 0 ]; then
    echo "  every declared link token is atomic (line wraps excepted)"
  fi
done

echo
if [ -n "$skipped" ]; then
  echo "SKIPPED (Biber or latexmk absent):$skipped"
  echo "The bibliography is the only site with stretchable URL glue, and the"
  echo "negative control lives there — this run did not exercise either."
fi
[ "$fail" -eq 0 ] && echo "ALL LINK-INTEGRITY FIXTURES PASSED" || echo "LINK-INTEGRITY FIXTURES FAILED"
exit "$fail"
