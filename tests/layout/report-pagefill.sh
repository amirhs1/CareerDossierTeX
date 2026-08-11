#!/usr/bin/env bash
# report-pagefill.sh — measure how full each page is (issue #334).
#
# The keep-together policy has always had two halves and only one of them was
# measured. `tests/layout/run.sh` asserts that material stays *together*: no
# list split leaving one item behind, no heading separated from what it
# introduces, no page ending on a section heading. Every one of those passes on
# a page that wastes a fifth of its text block, and nothing anywhere in this
# repository measured how full a page is. In documents whose entire constraint
# is a page limit, that is the more important half.
#
# Every other spacing decision here was settled by measurement — the
# line-breaking corpus rule (#316), the `\emergencystretch` passes (#310), the
# gap-collapse probes, the token-visibility sweep. Page fill should be settled
# the same way, and this is the instrument that lets it be.
#
# Like `review-page-two`, `review-matrix`, and `review-linebreak` this is an
# instrument, not an assertion: it is not part of `make check`, it carries no
# baseline, it writes only under the gitignored `build/`, and it commits
# nothing. The assertion side of the same measurement lives in run.sh, where it
# sits beside the keep assertions it complements — see the page-fill block
# there and `CDOSSIER_PAGE_FILL_MIN`.
#
# Method: rebuild every committed layout fixture with `\tracingpages=1`, parse
# the log with page-fill.awk — which documents the trace format and the two
# non-obvious things about reading it — and report each fixture that renders
# more than one page. Parsing the log is exact and needs no PDF tooling, which
# also keeps this portable: CI's texlive image has no poppler, and the
# extraction suite already works around that.
#
# Requirements: lualatex and awk. Deliberately nothing else.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../.." && pwd)"
work="$(mktemp -d "${TMPDIR:-/tmp}/careerdossier-pagefill.XXXXXX")"
output="$root/build/pagefill-review"
trap 'rm -rf "$work"' EXIT

if ! command -v lualatex >/dev/null 2>&1; then
  echo "MISSING required command: lualatex"
  exit 1
fi

mkdir -p "$output"
find "$output" -maxdepth 1 -type f \
  \( -name '*.txt' -o -name '*.md' -o -name '*.log' -o -name '*.tsv' \) -delete

export TEXINPUTS="$here:$root:${TEXINPUTS:-}"

report="$output/pagefill-report.txt"
baseline="$output/baseline.md"
records="$output/pagefill.tsv"
: >"$report"
: >"$records"

# Every committed fixture, in name order; the ones that render a single page
# are dropped after compiling, because their only page is their last and a short
# last page carries no information.
#
# The glob is the fixture list on purpose, and it is deliberately wider than
# `*two-page*`: `resume-section-need` renders two pages without saying so in its
# name, and a fixture list that trusted the name would have left one governed
# page out of the baseline. Reading the corpus rather than keeping a second
# register is the same rule run.sh's section-heading check follows.
fixtures=()
for tex in "$here"/*.tex; do
  fixtures+=("$(basename "$tex" .tex)")
done
if [ "${#fixtures[@]}" -eq 0 ]; then
  echo "FAILED: no fixture found in $here"
  exit 1
fi

fail=0
measured=0
singlepage=0

measure() {
  local base="$1" tex="$here/$1.tex"
  local pass pages parsed options

  for pass in 1 2; do
    if ! lualatex -halt-on-error -interaction=nonstopmode \
         -output-directory="$work" -jobname="$base" \
         "\\tracingpages=1 \\input{$tex}" >"$work/$base.stdout" 2>&1; then
      echo "FAILED: $base did not compile on pass $pass (see $work/$base.stdout)"
      fail=1
      return
    fi
  done

  # The fixture's own declared class options, so a row that looks anomalous can
  # be read against the settings that produced it rather than against class
  # defaults. `cv-two-page` in particular declares `fontsize=11pt`, and at class
  # defaults the same source renders one size larger.
  options="$(sed -n 's/^\\documentclass\[\([^]]*\)\].*/\1/p' "$tex" | head -1)"
  [ -n "$options" ] || options="class defaults"

  pages="$(grep -oE 'Output written on .*\([0-9]+ page' "$work/$base.log" \
           | grep -oE '\([0-9]+ page' | grep -oE '[0-9]+' | tail -1)"
  pages="${pages:-0}"

  parsed="$(awk -f "$here/page-fill.awk" "$work/$base.log")"
  cp "$work/$base.log" "$output/$base.log"

  # The parser identifies pages by TeX's own shipout marker rather than by
  # counting `%%` groups, because most `%%` groups are not pages. That
  # identification is an assumption about log format, so it is checked against
  # the log's own page count instead of being trusted.
  local counted
  counted="$(printf '%s\n' "$parsed" | grep -c '.' || true)"
  if [ "$counted" -ne "$pages" ]; then
    echo "FAILED: $base — parsed $counted page record(s), log reports $pages page(s)."
    echo "  The shipout-marker rule in page-fill.awk no longer matches this log."
    fail=1
    return
  fi

  # A single-page fixture has nothing a fill policy could govern: its only page
  # is its last one. It is still compiled and parsed, so the parse cross-check
  # above covers the whole corpus, but it contributes no rows.
  if [ "$pages" -lt 2 ]; then
    singlepage=$(( singlepage + 1 ))
    return
  fi
  measured=$(( measured + 1 ))

  {
    printf '%s\n' "$base"
    printf '  options: %s\n' "$options"
    printf '  pages:   %s\n\n' "$pages"
    printf '  %-5s %9s %9s %7s %9s %-9s %10s %9s %9s\n' \
      page goal used fill penalty kind next atom blank
    printf '%s\n' "$parsed" | awk -F'\t' '{
      mark = ($10 == 1) ? $1 "*" : $1
      printf "  %-5s %9.2f %9.2f %6.1f%% %9s %-9s %10s %9s %9.2f\n", \
        mark, $2, $3, $4, $5, $6, $7, $8, $9
    }'
    printf '\n'
  } >>"$report"

  printf '%s\n' "$parsed" | awk -F'\t' -v base="$base" -v opts="$options" \
    '{ printf "%s\t%s\t%s\n", base, opts, $0 }' >>"$records"
}

echo "Measuring page fill across ${#fixtures[@]} layout fixtures"
{
  printf '# CareerDossierTeX page-fill report (issue #334)\n'
  printf 'generated-utc: %s\n' "$(date -u +'%Y-%m-%dT%H:%M:%SZ')"
  printf 'commit: %s\n' "$(git -C "$root" rev-parse HEAD 2>/dev/null || echo unavailable)"
  printf 'engine: %s\n' "$(lualatex --version 2>/dev/null | head -1)"
  printf '\n'
  printf 'Heights are points. `fill` is `used` as a percentage of `\\pagegoal`.\n'
  printf '`penalty` is the penalty at the break actually taken; `next` is the\n'
  printf 'first candidate rejected after it and `atom` the difference — the size\n'
  printf 'of the material that would not fit, which is the number that says why\n'
  printf 'a page is short. Both read `-` when nothing was rejected.\n'
  printf '\n'
  printf '`kind` says what ended the page, and it matters more than the fill:\n'
  printf '\n'
  printf '  overflow  the page filled until the next atom did not fit. `atom`\n'
  printf '            is meaningful only here.\n'
  printf '  keep      a policy rule ended the page early — the bounded section\n'
  printf '            keep of #333, `\\CDossierSectionNeedLines`.\n'
  printf '  eject     the source ended the page (`\\newpage`, `\\vfill`, the\n'
  printf '            `\\end{document}` flush). How full such a page is says\n'
  printf '            nothing about page-break policy, so a fill assertion must\n'
  printf '            skip it. Both forced kinds print `p=-10000`; only the fil\n'
  printf '            stretch on the taken candidate tells them apart.\n'
  printf '\n'
  printf 'A `*` marks the last page. A short last page is normal and carries no\n'
  printf 'information; the fill check in run.sh skips it for that reason.\n'
  printf '\n'
} >>"$report"

for base in "${fixtures[@]}"; do
  measure "$base"
done
echo "  multi-page fixtures reported: $measured"
echo "  single-page fixtures skipped: $singlepage (their only page is their last)"

# The baseline table this issue asked to be reproducible rather than
# transcribed. Every non-last page appears, `eject` rows included and labelled
# rather than dropped: a table that silently omitted a quarter of the corpus
# would read as complete coverage when it is not.
{
  printf '# Page-fill baseline\n\n'
  printf 'Regenerated by `make review-pagefill`. Every page but each fixture'"'"'s\n'
  printf 'last, which is the set a fill policy could govern. Rows whose `kind` is\n'
  printf '`eject` are excluded from that set: their page was ended by the\n'
  printf 'fixture source, not by policy.\n\n'
  printf 'commit: `%s`\n\n' "$(git -C "$root" rev-parse HEAD 2>/dev/null || echo unavailable)"
  printf '| fixture | options | page | `\\pagegoal` | used | fill | penalty | kind | forcing atom | blank |\n'
  printf '|---|---|---:|---:|---:|---:|---:|---|---:|---:|\n'
  awk -F'\t' '$12 == 0 {
    printf "| `%s` | `%s` | %s | %.2fpt | %.2fpt | %.1f%% | %s | %s | %s | %.2fpt |\n", \
      $1, $2, $3, $4, $5, $6, $7, $8, ($10 == "-" ? "—" : $10 "pt"), $11
  }' "$records"
} >"$baseline"

nonlast="$(awk -F'\t' '$12 == 0' "$records" | wc -l | tr -d ' ')"
ejected="$(awk -F'\t' '$12 == 0 && $8 == "eject"' "$records" | wc -l | tr -d ' ')"
governed=$(( nonlast - ejected ))
worst="$(awk -F'\t' '$12 == 0 && $8 != "eject" { printf "%s\t%s\t%s\t%s\n", $6, $1, $3, $8 }' \
           "$records" | sort -n | head -1)"

{
  printf 'Summary\n\n'
  printf '  fixtures compiled:        %s\n' "${#fixtures[@]}"
  printf '  multi-page, reported:     %s\n' "$measured"
  printf '  single-page, skipped:     %s (their only page is their last)\n' "$singlepage"
  printf '  non-last pages:           %s\n' "$nonlast"
  printf '  of those, source-ejected: %s (excluded: fill is not policy there)\n' "$ejected"
  printf '  pages a policy governs:   %s\n' "$governed"
  printf '  lowest governed fill:     %s%% on %s page %s (%s)\n' \
    "$(printf '%s' "$worst" | cut -f1)" \
    "$(printf '%s' "$worst" | cut -f2)" \
    "$(printf '%s' "$worst" | cut -f3)" \
    "$(printf '%s' "$worst" | cut -f4)"
  printf '\n'
  printf 'No threshold is applied here, and none is applied by default in\n'
  printf 'run.sh either: #333 closed on the bounded section keep without\n'
  printf 'setting a minimum fill, and after #332/#339 the record families sit\n'
  printf 'at ordinary raggedbottom slack. Re-prove the enforcement hook with\n'
  printf '`CDOSSIER_PAGE_FILL_MIN=<pct> tests/layout/run.sh`.\n'
} >>"$report"

if [ "$fail" -ne 0 ]; then
  echo
  echo "PAGE-FILL REPORT INCOMPLETE"
  echo "Artifacts: $output"
  exit 1
fi

echo
echo "PAGE-FILL REPORT BUILT"
echo "Artifacts: $output"
echo "  $report"
echo "  $baseline"
echo "  $records"
