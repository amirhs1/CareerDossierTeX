#!/usr/bin/env bash
# run.sh — verify two-sided link contrast, CVD rendering, and PDF link styles.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../.." && pwd)"

texlua "$here/check-colors.lua" "$root/careerdossier-theme.sty"

build_dir="$(mktemp -d "${TMPDIR:-/tmp}/careerdossier-theme.XXXXXX")"
trap 'rm -rf "$build_dir"' EXIT
export TEXINPUTS="$root:${TEXINPUTS:-}"
export TEXMFVAR="${TEXMFVAR:-$build_dir/texmf-var}"

for preset in monochrome accent; do
  lualatex -halt-on-error -interaction=nonstopmode \
    -output-directory="$build_dir" "$here/link-$preset.tex" \
    > "$build_dir/link-$preset.stdout" 2>&1
done

annotation_dump="$build_dir/annotations.txt"
for preset in monochrome accent; do
  mutool show "$build_dir/link-$preset.pdf" 'pages/1/Annots/*' \
    > "$annotation_dump"
  if ! grep -qF '/Border [ 0 0 0 ]' "$annotation_dump"; then
    echo "LINK STYLE CHECK FAILED: $preset link has a rectangular fallback" >&2
    exit 1
  fi
  if grep -qF '/BS' "$annotation_dump"; then
    echo "LINK STYLE CHECK FAILED: $preset link has a border style" >&2
    exit 1
  fi
done

if lualatex -halt-on-error -interaction=nonstopmode \
    -output-directory="$build_dir" "$here/link-accent-without-theme.tex" \
    > "$build_dir/link-accent-without-theme.stdout" 2>&1; then
  echo "OPTION CHECK FAILED: inactive accent unexpectedly compiled" >&2
  exit 1
fi
if ! tr '\n' ' ' < "$build_dir/link-accent-without-theme.log" | tr -s ' ' \
    | grep -qF "'accent' option requires"; then
  echo "OPTION CHECK FAILED: inactive accent produced the wrong diagnostic" >&2
  exit 1
fi

echo "ALL THEME PDF LINK STYLE AND OPTION CHECKS PASSED"
