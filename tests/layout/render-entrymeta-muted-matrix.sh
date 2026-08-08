#!/usr/bin/env bash
# render-entrymeta-muted-matrix.sh — build the {column,inline} x
# {italic,gray,both,plain} reference matrix for the résumé and CV
# (issues #230, #271, #324).
#
# `entrymeta' and `muted' are the two options that both land on the same piece
# of the page: the entry heading's dates and location. `entrymeta' decides where
# that metadata sits and `muted' decides how it is de-emphasised, so the pair has
# to be reviewed as a grid rather than one option at a time. The combination
# worth looking hardest at is `entrymeta=inline' with an italic-bearing `muted',
# because that is the only place a de-emphasised run sits immediately beside the
# separator instead of at the far margin — the separator itself is deliberately
# never italic (see \CDossierEntryMetaSeparator), and this matrix is where a
# reviewer confirms that reads correctly rather than merely holds in a .tlg.
#
# `muted=plain' (issue #324) is the one column where the metadata carries no
# de-emphasis at all, so it is where a reviewer judges whether position and
# content still separate the cells from the title — under `inline', where they
# share the line, that judgement rests on the separator alone. It is also the
# class default, so `*-column-plain' is the appearance a document that sets
# neither option gets, and it carries the most review weight of the sixteen.
#
# Every other option is left at its class default. This is deliberate and is
# what separates this matrix from `review-matrix' (issue #147), which sweeps
# fontsize and margin with the semantic options fixed. Sweeping all four at once
# would be 72 PDFs and would not isolate anything; here fontsize, margin, paper,
# and bodyfont are whatever the class chooses, so every visible difference
# between two PDFs in this set is attributable to the two options named in its
# filename.
#
# `entrymeta' exists only on the two record classes, so only those two are built
# — the letter and statement classes have no entry headings. Each is represented
# by its existing canonical two-page fixture, so the grid exercises entries and
# bullet lists under real page-break pressure rather than a one-page stub, and
# the CV fixture additionally carries its publication list.
#
# Every combination must actually compile; a genuine compile failure aborts the
# run. Overfull boxes, missing glyphs, font substitutions, and unresolved
# references are instead collected as warnings, so one bad combination does not
# stop the other eleven from being produced for review.
#
# Whether the rendered result reads well — whether `|' is the right mark at the
# default size, whether gray metadata beside an upright separator is legible,
# whether the inline form crowds the heading — is a human visual review. This
# script produces the evidence; it does not judge it.
#
# PDFs, logs, and the review record are generated evidence under the gitignored
# build/ directory. They must not be committed.
#
# Requirements: lualatex. Run from anywhere; the repository root is placed on
# TEXINPUTS.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../.." && pwd)"
work="$(mktemp -d "${TMPDIR:-/tmp}/careerdossier-entrymeta-muted-matrix.XXXXXX")"
output="$root/build/entrymeta-muted-matrix"
trap 'rm -rf "$work"' EXIT

if ! command -v lualatex >/dev/null 2>&1; then
  echo "MISSING required command: lualatex"
  exit 1
fi

mkdir -p "$output"
find "$output" -maxdepth 1 -type f \( -name '*.pdf' -o -name '*.log' -o -name '*.txt' \) -delete

export TEXINPUTS="$here:$root:${TEXINPUTS:-}"

# `entrymeta' is the outer loop, so both the build order and a directory listing
# group all four `muted' values of one placement together — the order a reviewer
# compares them in, because the placement is the larger visual decision and the
# de-emphasis is the variation within it.
placements=(column inline)
emphases=(italic gray both plain)
diagnostic_jobs=()

compile_and_check() {
  local job="$1" source="$2" pass
  for pass in 1 2; do
    if ! (cd "$root" && lualatex -output-directory="$work" -jobname="$job" \
        -halt-on-error -interaction=nonstopmode "$source") \
        >"$work/$job.stdout" 2>&1; then
      echo "FAILED: $job did not compile on pass $pass (see $work/$job.stdout)"
      exit 1
    fi
  done

  local unexpected pages
  unexpected="$(grep -iE \
    'Warning:|Missing character|Font shape.*undefined|substituting|Undefined control sequence|Overfull' \
    "$work/$job.log" | grep -viE 'Neither unicode-math nor lua-unicode-math' || true)"
  pages="$(grep -oE 'Output written on .*\(([0-9]+) page' "$work/$job.log" \
           | grep -oE '\(([0-9]+) page' | grep -oE '[0-9]+' | tail -1)"
  cp "$work/$job.pdf" "$output/$job.pdf"
  cp "$work/$job.log" "$output/$job.log"

  if [ -n "$unexpected" ]; then
    diagnostic_jobs+=("$job")
    echo "  built: $job.pdf (${pages:-?} pages) — WARNING: see $job.log"
    printf '%s\n' "$unexpected" | sed 's/^/    /'
  else
    echo "  built: $job.pdf (${pages:-?} pages)"
  fi
}

# Rewrite the fixture's \documentclass line with the entrymeta/muted combination
# under test, and with nothing else: the fixtures name fontsize and margin
# explicitly, and dropping those is what makes this a default-everything-else
# matrix. Using awk, not sed, keeps this portable across BSD (macOS) and GNU
# (CI) tool differences.
render_class_matrix() {
  local class="$1" template="$2" prefix="$3"
  local placement emphasis job newline

  for placement in "${placements[@]}"; do
    for emphasis in "${emphases[@]}"; do
      job="${prefix}-${placement}-${emphasis}"
      # ENVIRON, not -v, carries the replacement: awk's -v assignment runs
      # backslash-escape processing on its value, which silently eats the
      # leading backslash off \documentclass. ENVIRON is not escape-processed.
      newline="\\documentclass[entrymeta=${placement}, muted=${emphasis}]{${class}}"
      NEWLINE="$newline" awk '
        $0 ~ /^\\documentclass/ { print ENVIRON["NEWLINE"]; next }
        { print }
      ' "$here/$template" >"$work/$job.tex"
      compile_and_check "$job" "$work/$job.tex"
    done
  done
}

echo "Building résumé entrymeta/muted matrix (resume-two-page.tex)"
render_class_matrix careerdossier-resume resume-two-page.tex resume

echo
echo "Building CV entrymeta/muted matrix (cv-two-page.tex)"
render_class_matrix careerdossier-cv cv-two-page.tex cv

count="$(find "$output" -maxdepth 1 -type f -name '*.pdf' | wc -l | tr -d ' ')"
if [ "$count" -ne 16 ]; then
  echo "FAILED: expected 16 PDFs, found $count"
  exit 1
fi

{
  echo "# CareerDossierTeX entrymeta/muted reference-matrix record (issues #230, #271, #324)"
  echo "generated-utc: $(date -u +'%Y-%m-%dT%H:%M:%SZ')"
  echo "commit: $(git -C "$root" rev-parse HEAD 2>/dev/null || echo unavailable)"
  echo "combinations: 2 placements x 4 de-emphasis values x 2 record classes = 16"
  echo "file naming: <type>-<entrymeta>-<muted>.pdf"
  echo "record classes:"
  echo "  résumé - resume-two-page.tex"
  echo "  CV     - cv-two-page.tex"
  echo "every other option is at its class default (fontsize, margin, paper, bodyfont)"
  echo
  echo "What to compare:"
  echo "  down a column  - the four muted values at one placement"
  echo "  across a row   - column vs inline at one muted value"
  echo "  hardest case   - *-inline-italic and *-inline-both: the only place a"
  echo "                   de-emphasised run sits directly beside the separator,"
  echo "                   which must stay upright while the cell after it slants"
  echo "  plain column   - *-*-plain carries no de-emphasis at all and is the"
  echo "                   class default, so *-column-plain is what a document"
  echo "                   that sets neither option renders; judge whether"
  echo "                   position and content still separate the metadata"
  echo
  if [ "${#diagnostic_jobs[@]}" -eq 0 ]; then
    echo "log diagnostics: none"
  else
    echo "log diagnostics: ${#diagnostic_jobs[@]} combination(s) logged a warning — see the matching .log:"
    printf '  %s\n' "${diagnostic_jobs[@]}"
  fi
  echo
  echo "Review each PDF using the checklist in CONTRIBUTING.md."
} >"$output/review-record.txt"

echo
echo "ENTRYMETA/MUTED REFERENCE MATRIX BUILT"
echo "Artifacts: $output"
if [ "${#diagnostic_jobs[@]}" -gt 0 ]; then
  echo "${#diagnostic_jobs[@]} combination(s) logged a warning: ${diagnostic_jobs[*]}"
fi
