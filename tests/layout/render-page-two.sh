#!/usr/bin/env bash
# render-page-two.sh — build the five-family and statement page-two review set.
#
# The canonical short-name set covers résumé, industry letter, academic CV,
# academic letter, and the existing two-page research statement. The three
# families with continuation headers are also rendered with a deliberately
# long name. The set also renders all six existing specialized statement
# examples and the default-interest long-fields fixture. PDFs and PNGs are
# review artifacts under build/, never source.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../.." && pwd)"
work="$(mktemp -d "${TMPDIR:-/tmp}/careerdossier-page-two.XXXXXX")"
output="$root/build/page-two-review"
trap 'rm -rf "$work"' EXIT

for command in lualatex pdfinfo pdftoppm; do
  if ! command -v "$command" >/dev/null 2>&1; then
    echo "MISSING required command: $command"
    exit 1
  fi
done

mkdir -p "$output"
find "$output" -maxdepth 1 -type f \
  \( -name '*.pdf' -o -name '*.png' -o -name '*.log' -o -name '*.txt' \) \
  -delete

export TEXINPUTS="$here:$root:${TEXINPUTS:-}"

compile_source_and_render() {
  local job="$1" source="$2"
  local pass pages unexpected
  for pass in 1 2; do
    if ! (cd "$root" && lualatex -output-directory="$work" -jobname="$job" \
        -halt-on-error -interaction=nonstopmode "$source") \
        >"$work/$job.stdout" 2>&1; then
      echo "FAILED: $job did not compile on pass $pass (see $work/$job.stdout)"
      exit 1
    fi
  done

  pages="$(pdfinfo "$work/$job.pdf" | awk '/^Pages:/ { print $2 }')"
  if [ "$pages" -ne 2 ]; then
    echo "FAILED: $job must produce exactly two pages (got $pages)"
    exit 1
  fi

  unexpected="$(grep -iE \
    'Warning:|Missing character|Font shape.*undefined|substituting|Undefined control sequence|Overfull' \
    "$work/$job.log" | grep -viE 'Neither unicode-math nor lua-unicode-math' || true)"
  if [ -n "$unexpected" ]; then
    echo "FAILED: $job produced unexpected log diagnostics"
    printf '%s\n' "$unexpected" | sed 's/^/  /'
    exit 1
  fi

  cp "$work/$job.pdf" "$output/$job.pdf"
  cp "$work/$job.log" "$output/$job.log"
  pdftoppm -f 2 -l 2 -singlefile -png -r 150 \
    "$work/$job.pdf" "$output/$job-page-2" >/dev/null 2>&1
  echo "  rendered: $job-page-2.png"
}

compile_layout_with_name() {
  local family="$1" source="$2" variant="$3" review_name="$4"
  local job="${family}-${variant}"
  sed "s/Ada Lovelace/$review_name/g" "$here/$source" >"$work/$job.tex"
  compile_source_and_render "$job" "$work/$job.tex"
}

compile_repository_source() {
  local job="$1" source="$2"
  compile_source_and_render "$job" "$root/$source"
}

echo "Building canonical short-name page-two renders"
compile_layout_with_name resume resume-two-page.tex short "Ada Lovelace"
compile_layout_with_name industry-letter letter-two-page.tex short "Ada Lovelace"
compile_layout_with_name cv cv-two-page.tex short "Ada Lovelace"
compile_layout_with_name academic-letter letter-academic-two-page.tex short "Ada Lovelace"
compile_layout_with_name statement statement-two-page.tex short "Ada Lovelace"

echo
echo "Building long-name continuation-header renders"
long_name="Alexandria Catherine Montgomery-Worthington"
compile_layout_with_name cv cv-two-page.tex long "$long_name"
compile_layout_with_name academic-letter letter-academic-two-page.tex long "$long_name"
compile_layout_with_name statement statement-two-page.tex long "$long_name"

echo
echo "Building specialized statement-example page-two renders"
compile_repository_source statement-example-research \
  examples/statements/research-statement.tex
compile_repository_source statement-example-teaching \
  examples/statements/teaching-statement.tex
compile_repository_source statement-example-teaching-philosophy \
  examples/statements/teaching-philosophy-statement.tex
compile_repository_source statement-example-diversity \
  examples/statements/diversity-statement.tex
compile_repository_source statement-example-artist \
  examples/statements/artist-statement.tex
compile_repository_source statement-example-purpose \
  examples/statements/statement-of-purpose.tex

echo
echo "Building default-interest long-fields page-two render"
compile_repository_source statement-interest-long-fields \
  tests/layout/statement-interest-long-fields-two-page.tex

render_count="$(find "$output" -maxdepth 1 -type f -name '*-page-2.png' | wc -l | tr -d ' ')"
if [ "$render_count" -ne 15 ]; then
  echo "FAILED: expected 15 page-two PNGs, found $render_count"
  exit 1
fi

{
  echo "# CareerDossierTeX page-two review record"
  echo "generated-utc: $(date -u +'%Y-%m-%dT%H:%M:%SZ')"
  echo "commit: $(git -C "$root" rev-parse HEAD 2>/dev/null || echo unavailable)"
  echo "short-name: Ada Lovelace"
  echo "long-name: $long_name"
  echo "render-count: $render_count"
  echo "statement-examples: research, teaching, teaching-philosophy, diversity, artist, purpose"
  echo "default-interest-long-fields: statement-interest-long-fields-page-2.png"
  echo
  echo "Review every *-page-2.png using the checklist in CONTRIBUTING.md."
} >"$output/review-record.txt"

echo
echo "PAGE-TWO REVIEW SET BUILT"
echo "Artifacts: $output"
