#!/usr/bin/env bash
# render-page-two.sh — build the five-family page-two visual-review set.
#
# The canonical short-name set covers résumé, industry letter, academic CV,
# academic letter, and the existing two-page research statement. The three
# families with continuation headers are also rendered with a deliberately
# long name. PDFs and PNGs are review artifacts under build/, never source.
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

compile_and_render() {
  local family="$1" source="$2" variant="$3" review_name="$4"
  local job="${family}-${variant}" pass pages unexpected

  sed "s/Ada Lovelace/$review_name/g" "$here/$source" >"$work/$job.tex"

  for pass in 1 2; do
    if ! lualatex -output-directory="$work" -jobname="$job" \
        -halt-on-error -interaction=nonstopmode "$work/$job.tex" \
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

echo "Building canonical short-name page-two renders"
compile_and_render resume resume-two-page.tex short "Ada Lovelace"
compile_and_render industry-letter letter-two-page.tex short "Ada Lovelace"
compile_and_render cv cv-two-page.tex short "Ada Lovelace"
compile_and_render academic-letter letter-academic-two-page.tex short "Ada Lovelace"
compile_and_render statement statement-two-page.tex short "Ada Lovelace"

echo
echo "Building long-name continuation-header renders"
long_name="Alexandria Catherine Montgomery-Worthington"
compile_and_render cv cv-two-page.tex long "$long_name"
compile_and_render academic-letter letter-academic-two-page.tex long "$long_name"
compile_and_render statement statement-two-page.tex long "$long_name"

{
  echo "# CareerDossierTeX page-two review record"
  echo "generated-utc: $(date -u +'%Y-%m-%dT%H:%M:%SZ')"
  echo "commit: $(git -C "$root" rev-parse HEAD 2>/dev/null || echo unavailable)"
  echo "short-name: Ada Lovelace"
  echo "long-name: $long_name"
  echo
  echo "Review every *-page-2.png using the checklist in CONTRIBUTING.md."
} >"$output/review-record.txt"

echo
echo "PAGE-TWO REVIEW SET BUILT"
echo "Artifacts: $output"
