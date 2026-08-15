#!/usr/bin/env bash
# report-pages.sh — measure the boundaries a \vbox fixture cannot reach.
#
# The identity stack (name, title, subtitle, affiliation, contact) and the
# letter's letterhead and recipient block are assembled by
# \MakeCDossierHeader and \MakeCDossierLetterhead into page-level material, so
# tests/spacing/report.sh -- which measures free-standing \vbox fragments --
# does not see them. This runner instead hooks \AtBeginShipout on the real
# layout fixtures and walks the shipped page.
#
# The two runners are complementary, not redundant: this one reaches every
# boundary but names them only by the text on either side, while report.sh
# names each boundary by construction. Where both reach a boundary they must
# agree, which is the cross-check worth having.
#
# Requirements: lualatex. Run from the repository root.
set -euo pipefail

root="$(cd "$(dirname "$0")/../.." && pwd)"
out="$root/build/spacing"
mkdir -p "$out"

if ! command -v lualatex >/dev/null 2>&1; then
  echo "MISSING required command: lualatex"
  exit 1
fi

tsv="$out/pages.tsv"
printf 'class\tsize\tpath\tindex\tabove\tbelow\tstructural\tinterline\twhite\n' >"$tsv"

# The hook is injected immediately after \documentclass so it is in force for
# every shipout, including the first page.
#
# `shipout/before' with `\ShipoutBox' is the current kernel interface.
# \AtBeginShipout is atbegshi's, which the classes do not load, so it is
# undefined at this point in the preamble.
hook='\directlua{dofile("tests/spacing/probe.lua")}\AddToHook{shipout/before}{\directlua{cdossier_probe.report_page(\number\ShipoutBox, "page")}}'

run_one() {
  local class="$1" fixture="$2" extra="$3" size="$4"
  local job="pages-${class#careerdossier-}-${size}"
  local options="${extra:+${extra}, }fontsize=${size}"
  local generated="$out/$job.tex"

  NEWLINE="\\documentclass[${options}]{${class}}" HOOK="$hook" awk '
    $0 ~ /^\\documentclass/ { print ENVIRON["NEWLINE"]; print ENVIRON["HOOK"]; next }
    { print }
  ' "$root/tests/layout/$fixture" >"$generated"

  if ! (cd "$root" && max_print_line=10000 lualatex \
        -output-directory="$out" -jobname="$job" \
        -halt-on-error -interaction=nonstopmode "$generated") \
        >"$out/$job.stdout" 2>&1; then
    echo "FAILED: $job did not compile (see $out/$job.stdout)"
    exit 1
  fi
  if grep -q nullfont "$out/$job.log"; then
    echo "FAILED: $job typeset nullfont — the measurements would be meaningless"
    exit 1
  fi

  awk -F'\t' -v c="$class" -v s="$size" '
    /^CDPAGE/ { print c "\t" s "\t" $3 "\t" $4 "\t" $5 "\t" $6 "\t" $7 "\t" $8 "\t" $9 }
  ' "$out/$job.stdout" >>"$tsv"

  echo "  measured: $job"
}

for size in 10pt 11pt 12pt; do
  run_one careerdossier-resume    resume-two-page.tex    ""              "$size"
  run_one careerdossier-cv        cv-two-page.tex        ""              "$size"
  run_one careerdossier-statement statement-two-page.tex "type=research" "$size"
  run_one careerdossier-letter    letter-two-page.tex    ""              "$size"
done

echo
echo "Page boundaries: $tsv"
