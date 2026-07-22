#!/usr/bin/env bash
# run.sh — verify link-theme contrast and approximate CVD rendering.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../.." && pwd)"

texlua "$here/check-colors.lua" "$root/careerdossier-theme.sty"
