#!/usr/bin/env bash
# report.sh — measure every vertical boundary in every class at every body size.
#
# Emits one TSV row per boundary to build/spacing/boundaries.tsv:
#
#   class  size  context  index  boundary  structural  interline  b2b  white
#          prev_depth prev_ink_depth next_height next_ink_height
#
# `structural' is the explicit glue a token asks for; `white' is the visible
# band between the two boxes. They differ by the interline glue, which TeX
# computes as `baselineskip - depth(previous) - height(next)' and which no
# token can reach -- so a token owns the structural gap and only partly
# governs the white one.
#
# The \documentclass line is rewritten per class and size, the same technique
# tests/layout/render-size-margin-matrix.sh uses, so one fixture serves both
# record classes and one serves the prose class.
#
# max_print_line is raised because TeX wraps terminal output at 79 columns by
# default, which silently truncates the wider rows into unparseable fragments.
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

tsv="$out/boundaries.tsv"
tok="$out/tokens.tsv"
printf 'class\tsize\tcontext\tindex\tboundary\tstructural\tinterline\tb2b\twhite\tprevD\tprevInkD\tnextH\tnextInkH\n' >"$tsv"
printf 'class\tsize\ttoken\tpt\tratio\n' >"$tok"

run_one() {
  local class="$1" fixture="$2" extra="$3" size="$4"
  local job="${class#careerdossier-}-${size}"
  local options="${extra:+${extra}, }fontsize=${size}"
  local generated="$out/$job.tex"

  NEWLINE="\\documentclass[${options}]{${class}}" awk '
    $0 ~ /^\\documentclass/ { print ENVIRON["NEWLINE"]; next }
    { print }
  ' "$root/tests/spacing/$fixture" >"$generated"

  if ! (cd "$root" && max_print_line=10000 lualatex \
        -output-directory="$out" -jobname="$job" \
        -halt-on-error -interaction=nonstopmode "$generated") \
        >"$out/$job.stdout" 2>&1; then
    echo "FAILED: $job did not compile (see $out/$job.stdout)"
    exit 1
  fi

  # A sandboxed LuaLaTeX run without a writable font cache typesets nullfont
  # and produces numbers that look plausible and mean nothing. Refuse them.
  if grep -q nullfont "$out/$job.log"; then
    echo "FAILED: $job typeset nullfont — the measurements would be meaningless"
    exit 1
  fi

  awk -F'\t' -v c="$class" -v s="$size" '
    /^CDPROBE/ { print c "\t" s "\t" $2 "\t" $3 "\t" $4 "\t" $5 "\t" $6 "\t" $7 "\t" $8 "\t" $9 "\t" $10 "\t" $11 "\t" $12 }
  ' "$out/$job.stdout" >>"$tsv"

  awk -F'\t' -v c="$class" -v s="$size" '
    /^CDTOKEN/ { print c "\t" s "\t" $2 "\t" $3 "\t" $4 }
  ' "$out/$job.stdout" >>"$tok"

  echo "  measured: $job"
}

for size in 10pt 11pt 12pt; do
  run_one careerdossier-resume    record.tex ""              "$size"
  run_one careerdossier-cv        record.tex ""              "$size"
  run_one careerdossier-statement prose.tex  "type=research" "$size"
  run_one careerdossier-letter    letter.tex ""              "$size"
done

# Record against prose section headings (#420). The rule is part of a record
# section heading, so its rule-to-body white is compared with the white a prose
# section leaves between its heading and the text below. The prose white
# includes interline glue and so depends on the heading's descenders, which is
# why it is a band: its two ends are the same two heading texts both fixtures
# measure. The approved tolerance is that the record white lies inside the band
# and within one grid step (1/16 of the body baseline) of its midpoint, with
# the white above identical. This only reports; it does not fail the run.
alike="$out/section-alike.tsv"
awk -F'\t' -v OFS='\t' '
  FNR == NR {
    if ($3 == "baselineskip") base[$2] = $4
    next
  }
  $3 == "section" && $5 == "rule -> body" { rule[$1, $2] = $9 }
  $3 == "section-no-descender" && $5 == "rule -> body" { rule2[$1, $2] = $9 }
  $3 == "section" && $5 == "body -> section heading" { above[$1, $2] = $9 }
  $1 == "careerdossier-statement" && $3 == "section" && $5 == "section heading -> prose" { pn[$2] = $9 }
  $1 == "careerdossier-statement" && $3 == "section-descender" && $5 == "section heading -> prose" { pd[$2] = $9 }
  $1 == "careerdossier-statement" && $3 == "section" && $5 == "prose -> section heading" { pa[$2] = $9 }
  END {
    print "class", "size", "above", "prose-above", "rule-to-body", "prose-descender", "prose-plain", "midpoint", "difference", "step", "verdict"
    n = split("careerdossier-resume careerdossier-cv", classes, " ")
    split("10pt 11pt 12pt", sizes, " ")
    for (i = 1; i <= n; i++) for (j = 1; j <= 3; j++) {
      c = classes[i]; s = sizes[j]
      lo = pd[s]; hi = pn[s]; mid = (lo + hi) / 2; step = base[s] / 16
      w = rule[c, s]; diff = w - mid
      ok = (w >= lo && w <= hi && (diff < 0 ? -diff : diff) <= step \
            && rule2[c, s] == w && above[c, s] == pa[s])
      printf "%s\t%s\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%+.3f\t%.3f\t%s\n", \
        c, s, above[c, s], pa[s], w, lo, hi, mid, diff, step, ok ? "within" : "OUTSIDE"
    }
  }
' "$tok" "$tsv" >"$alike"

echo
echo "Record against prose section headings (#420):"
column -t -s "$(printf '\t')" "$alike"

echo
echo "Boundaries: $tsv"
echo "Tokens:     $tok"
echo "Alike:      $alike"
