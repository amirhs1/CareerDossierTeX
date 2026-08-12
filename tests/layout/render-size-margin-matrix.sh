#!/usr/bin/env bash
# render-size-margin-matrix.sh — build the {normal,narrow} x {10pt,11pt,12pt}
# reference matrix across all four document classes (issue #147).
#
# Each PDF is named <type>-<margin>-<fontsize>.pdf, and the margin is the outer
# loop, so both the build order and a directory listing group every size of one
# margin preset together — the order a reviewer compares them in (issue #195).
#
# Each document class is represented by its existing canonical two-page
# fixture — résumé, CV, industry letter, research statement — so the matrix
# exercises entries, itemized lists, prose paragraphs, and section/statement
# headings under real page-break pressure, not a one-page stub. The statement
# class is represented by a single type (research); statement-type-specific
# rendering is already covered by the five-family page-two review and the
# statement-title regression, so it is not multiplied into this matrix.
#
# Every combination must actually compile; a genuine compile failure aborts
# the run. Overfull boxes, missing glyphs, font substitutions, and unresolved
# references are instead collected as warnings: issue #147's "no overfull
# boxes ... in any log" is a criterion the human reviewer checks against the
# 24 built PDFs, not a gate that should stop the other combinations from being
# produced. Final rhythm and proportion correctness (heading-to-rule vs.
# rule-to-content gaps, whether spacing feels cramped or loose at each size)
# stays a human visual review.
#
# PDFs, logs, and the review record are generated evidence under the
# gitignored build/ directory. They must not be committed.
#
# Requirements: lualatex. Run from anywhere; the repository root is placed on
# TEXINPUTS.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../.." && pwd)"
work="$(mktemp -d "${TMPDIR:-/tmp}/careerdossier-size-margin-matrix.XXXXXX")"
output="$root/build/size-margin-matrix"
trap 'rm -rf "$work"' EXIT

if ! command -v lualatex >/dev/null 2>&1; then
  echo "MISSING required command: lualatex"
  exit 1
fi

mkdir -p "$output"
find "$output" -maxdepth 1 -type f \( -name '*.pdf' -o -name '*.log' -o -name '*.txt' \) -delete

export TEXINPUTS="$here:$root:${TEXINPUTS:-}"

sizes=(10pt 11pt 12pt)
margins=(normal narrow)
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

# Rewrite the fixture's \documentclass line with the size/margin combination
# under test, preserving any other class option the fixture already sets
# (only the statement fixture's type=research). Using awk, not sed, keeps this
# portable across BSD (macOS) and GNU (CI) tool differences.
render_class_matrix() {
  local class="$1" extra_options="$2" template="$3" prefix="$4"
  local size margin job options newline

  for margin in "${margins[@]}"; do
    for size in "${sizes[@]}"; do
      job="${prefix}-${margin}-${size}"
      options="fontsize=${size}, margin=${margin}"
      [ -n "$extra_options" ] && options="${extra_options}, ${options}"
      # ENVIRON, not -v, carries the replacement: awk's -v assignment runs
      # backslash-escape processing on its value, which silently eats the
      # leading backslash off \documentclass. ENVIRON is not escape-processed.
      newline="\\documentclass[${options}]{${class}}"
      NEWLINE="$newline" awk '
        $0 ~ /^\\documentclass/ { print ENVIRON["NEWLINE"]; next }
        { print }
      ' "$here/$template" >"$work/$job.tex"
      compile_and_check "$job" "$work/$job.tex"
    done
  done
}

echo "Building résumé size/margin matrix (resume-two-page.tex)"
render_class_matrix careerdossier-resume "" resume-two-page.tex resume

echo
echo "Building CV size/margin matrix (cv-two-page.tex)"
render_class_matrix careerdossier-cv "" cv-two-page.tex cv

echo
echo "Building industry-letter size/margin matrix (letter-two-page.tex)"
render_class_matrix careerdossier-letter "" letter-two-page.tex letter

echo
echo "Building research-statement size/margin matrix (statement-two-page.tex)"
render_class_matrix careerdossier-statement "type=research" statement-two-page.tex statement

count="$(find "$output" -maxdepth 1 -type f -name '*.pdf' | wc -l | tr -d ' ')"
if [ "$count" -ne 24 ]; then
  echo "FAILED: expected 24 PDFs, found $count"
  exit 1
fi

{
  echo "# CareerDossierTeX size/margin reference-matrix record (issue #147)"
  echo "generated-utc: $(date -u +'%Y-%m-%dT%H:%M:%SZ')"
  echo "commit: $(git -C "$root" rev-parse HEAD 2>/dev/null || echo unavailable)"
  echo "combinations: 2 margins x 3 sizes x 4 document types = 24"
  echo "file naming: <type>-<margin>-<fontsize>.pdf"
  echo "document types:"
  echo "  résumé   - resume-two-page.tex"
  echo "  CV       - cv-two-page.tex"
  echo "  letter   - letter-two-page.tex (industry family)"
  echo "  statement - statement-two-page.tex (type=research; single representative type)"
  echo
  if [ "${#diagnostic_jobs[@]}" -eq 0 ]; then
    echo "log diagnostics: none"
  else
    echo "log diagnostics: ${#diagnostic_jobs[@]} combination(s) logged a warning — see the matching .log:"
    printf '  %s\n' "${diagnostic_jobs[@]}"
  fi
  echo
  echo "Review each PDF using the checklist in docs/TESTING.md."
} >"$output/review-record.txt"

echo
echo "SIZE/MARGIN REFERENCE MATRIX BUILT"
echo "Artifacts: $output"
if [ "${#diagnostic_jobs[@]}" -gt 0 ]; then
  echo "${#diagnostic_jobs[@]} combination(s) logged a warning: ${diagnostic_jobs[*]}"
fi
