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

for preset in monochrome accent print; do
  lualatex -halt-on-error -interaction=nonstopmode \
    -output-directory="$build_dir" "$here/link-$preset.tex" \
    > "$build_dir/link-$preset.stdout" 2>&1
done

annotation_dump="$build_dir/annotations.txt"
for preset in monochrome accent print; do
  mutool show "$build_dir/link-$preset.pdf" 'pages/1/Annots/*' \
    > "$annotation_dump"
  if ! grep -qF '/Border [ 0 0 0 ]' "$annotation_dump"; then
    echo "LINK STYLE CHECK FAILED: $preset link has a rectangular fallback" >&2
    exit 1
  fi
  case "$preset" in
    monochrome|accent)
      if ! grep -qF '/S /U' "$annotation_dump" ||
         ! grep -qF '/W .6' "$annotation_dump"; then
        echo "LINK STYLE CHECK FAILED: $preset link is not underlined" >&2
        exit 1
      fi
      ;;
    print)
      if grep -qF '/BS' "$annotation_dump"; then
        echo "LINK STYLE CHECK FAILED: print link has a border style" >&2
        exit 1
      fi
      ;;
  esac
done

echo "ALL THEME PDF LINK STYLE CHECKS PASSED"
