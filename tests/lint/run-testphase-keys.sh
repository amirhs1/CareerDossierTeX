#!/usr/bin/env bash
# run-testphase-keys.sh — LaTeX Lab testphase keys stay in their owner (#478)
#
# `docs/ARCHITECTURE.md', "Testphase interfaces stay behind one wrapper", sets
# the rule this enforces: an unstable LaTeX Lab testphase interface is reached
# only through a CDossier-owned wrapper in `careerdossier-components.sty'. The
# stable tagpdf expl3 API (`\tag_...') is exempt and is not checked here.
#
# WHAT IT ASSERTS
#
# No Work file other than `careerdossier-components.sty' names a LaTeX Lab
# block-template vertical-space key, in code or in a comment. The Work files
# are the `.sty' and `.cls' entries of `manifest.txt'.
#
# Comments count. That is the maintainer's decision on #478 (2026-11-05): a
# comment naming a testphase key outside its owner is a sign the rule is being
# worked around, so the search reads every line and strips nothing.
#
# THE KEY LIST
#
# The six vertical-space keys `latex-lab-testphase-block.sty' declares for its
# block templates, read from that file in TeX Live 2026:
# begin-vspace, begin-extra-vspace, begin-unchained-vspace, end-vspace,
# end-extra-vspace, para-vspace. A key LaTeX Lab adds later is not caught until
# it is added to KEYS below.
#
# THE CONTROLS
#
# A search that finds nothing reads the same as one that cannot see. So the
# controls run the same `scan' over inputs whose verdict is known:
#
#   1. the owner itself, without the owner exemption, must produce hits;
#   2. tests/lint/fixtures/testphasefixture-code.cls sets a key in code: hit;
#   3. tests/lint/fixtures/testphasefixture-comment.cls names one in a
#      comment: hit, which is what makes "comments count" a tested claim;
#   4. tests/lint/fixtures/testphasefixture-clean.cls calls the stable tagpdf
#      API and names no key: no hit.
#
# Requirements: bash, awk, and git. Run from anywhere. The search is
# `git grep -F': the keys are literal strings, and no process substitution is
# used, because some sandboxed environments deny /dev/fd (#392).
set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../.." && pwd)"
owner="careerdossier-components.sty"
fail=0

KEYS="begin-vspace begin-extra-vspace begin-unchained-vspace end-vspace end-extra-vspace para-vspace"

# scan <file>... -- every line naming a key, as file:line:text. The owner is
# skipped unless SCAN_OWNER=1, which only control 1 sets.
scan() {
  local f args=()
  for k in $KEYS; do args+=(-e "$k"); done
  for f in "$@"; do
    if [ "$(basename "$f")" = "$owner" ] && [ "${SCAN_OWNER:-0}" != "1" ]; then
      continue
    fi
    git -C "$root" grep --no-index -n -F "${args[@]}" -- "$f" 2>/dev/null || true
  done
}

# The Work's .sty and .cls files, from manifest.txt: its lines name a path in
# the first column, and no Work path contains a space.
work=()
for f in $(awk '$1 ~ /^careerdossier-.*\.(sty|cls)$/ { print $1 }' "$root/manifest.txt"); do
  work+=("$root/$f")
done

echo "== ASSERTION: no Work file but $owner names a testphase key =="
if [ "${#work[@]}" -eq 0 ]; then
  echo "  FAIL: manifest.txt listed no .sty or .cls file, so nothing was searched."
  fail=1
else
  hits="$(scan "${work[@]}")"
  if [ -n "$hits" ]; then
    printf '%s\n' "$hits" | sed "s|^$root/||; s/^/  /"
    echo
    echo "  Each line above names a LaTeX Lab testphase key outside $owner."
    echo "  Reach it through the wrapper there instead; see docs/ARCHITECTURE.md,"
    echo "  \"Testphase interfaces stay behind one wrapper\"."
    fail=1
  else
    echo "  none (${#work[@]} Work files searched)"
  fi
fi

echo
echo "== CONTROLS =="
control() { # <label> <expect: hit|none> <file> [SCAN_OWNER]
  local label="$1" expect="$2" file="$3" got
  got="$(SCAN_OWNER="${4:-0}" scan "$file")"
  if { [ "$expect" = hit ] && [ -n "$got" ]; } || { [ "$expect" = none ] && [ -z "$got" ]; }; then
    printf '  %-34s %s as intended\n' "$label" "$expect"
  else
    printf '  %-34s FAILED: expected %s\n' "$label" "$expect"
    fail=1
  fi
}
control "1 owner, no exemption"     hit  "$root/$owner" 1
control "2 key set in code"         hit  "$here/fixtures/testphasefixture-code.cls"
control "3 key named in a comment"  hit  "$here/fixtures/testphasefixture-comment.cls"
control "4 stable tagpdf API only"  none "$here/fixtures/testphasefixture-clean.cls"

echo
if [ "$fail" -eq 0 ]; then
  echo "TESTPHASE KEY LINT PASSED"
else
  echo "TESTPHASE KEY LINT FAILED"
fi
exit "$fail"
