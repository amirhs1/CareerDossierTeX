#!/usr/bin/env bash
# run-section-sign.sh — no SECTION SIGN in tracked files (issue #520)
#
# `docs/NAMING-CONVENTION.md', "Markdown headings carry no section number",
# says a cross-reference names its heading rather than numbering it, and gives
# the form: `path' section "Heading". Before #520 the tree carried four
# spellings of that join at once -- U+00A7 with a quoted heading (12 lines, the
# de-facto form since #502), U+00A7 with a number against an external document
# (11 lines), U+00A7 as a bare noun in the rule itself, and a plain comma in
# the convention document's own example. Nothing stated which was right, which
# is why all four survived.
#
# WHAT IT ASSERTS
#
# No tracked file contains U+00A7. One rule, one character, no exception list.
#
# The ban is over the character and not over any spelling of it, because an
# exception list is what let the four forms coexist: a rule that permits
# U+00A7 in some position has to be read before it can be obeyed, and a
# contributor copying the nearest example never reads it. A character that
# appears nowhere needs no reading.
#
# WHAT IT DOES NOT ASSERT
#
# Nothing about LaTeX. `\section', `\subsection', `\subsubsection',
# \__cdossier_components_subsection:n, and the `cv-subsection' fixture group
# are LaTeX's names for document levels; #520 is scoped to how prose cites a
# heading in another document, and touches none of them. This runner cannot
# confuse the two, because it looks for one character that appears in neither.
#
# WHY THE PATTERN IS BUILT FROM BYTES
#
# A runner that spelled the character literally would match itself, and the
# assertion would fail on a correct tree -- the one failure mode that makes a
# guard worse than no guard, because the fix for it is to weaken the guard.
# `printf' keeps the byte sequence out of every tracked file, this one
# included, so the assertion is over the whole repository with no carve-out.
#
# THE CONTROL
#
# A guard that reports "no hits" is indistinguishable from a guard that never
# ran; #333 and #332 both shipped bounds no fixture reached. Control 1 below
# writes the byte sequence to a scratch file and runs the same search over it
# through the same function, so a pass reports that the search can still see
# what it is looking for. It runs `git grep --no-index' rather than a second
# tool: a control that exercises a different code path from the assertion
# stops covering it (#399).

set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../.." && pwd)"
fail=0

# U+00A7 in UTF-8. Never written literally -- see "WHY THE PATTERN IS BUILT
# FROM BYTES" above.
sign="$(printf '\302\247')"

# A self-check on the construction. `printf' is the one moving part between the
# code point and the search, and a build whose printf did not emit two bytes
# would hand every search below an empty or wrong pattern and report a clean
# tree. Length is measured in bytes, so LC_ALL=C.
sign_bytes="$(LC_ALL=C printf '%s' "$sign" | wc -c | tr -d ' ')"
if [ "$sign_bytes" != "2" ]; then
  echo "FAIL: the U+00A7 pattern is $sign_bytes bytes, expected 2."
  echo "      Every search below would be over the wrong pattern."
  exit 1
fi

# scan <git-grep-arg>... -- the one search both the assertion and the control
# run. -F is literal: the pattern is bytes, not an expression, and a byte-range
# ERE does not match bytes under ugrep (#514).
scan() {
  git -C "$root" grep -n -F -e "$sign" "$@"
}

echo "== ASSERTION: no tracked file contains U+00A7 =="
hits="$(scan -- . || true)"
if [ -n "$hits" ]; then
  echo "$hits" | sed 's/^/  /'
  echo
  echo "  Each line above carries U+00A7. Cite the heading instead:"
  echo '    `docs/TESTING.md` section "Coverage expectations"'
  echo "  See docs/NAMING-CONVENTION.md, \"Markdown headings carry no section"
  echo "  number\"."
  fail=1
else
  echo "  none"
fi

echo
echo "== CONTROL 1: the search still finds the character it bans =="
scratch="$root/build/section-sign-selftest"
rm -rf "$scratch"
mkdir -p "$scratch"
printf 'a %s b\n' "$sign" > "$scratch/positive.txt"
if git -C "$root" grep --no-index -n -F -e "$sign" -- "$scratch/positive.txt" \
     > /dev/null 2>&1; then
  echo "  OK: the pattern matches a planted occurrence."
else
  echo "  FAIL: the pattern did not match a planted occurrence, so the"
  echo "        assertion above reports nothing whether or not the tree is"
  echo "        clean."
  fail=1
fi
rm -rf "$scratch"

echo
if [ "$fail" -eq 0 ]; then
  echo "SECTION SIGN LINT PASSED"
else
  echo "SECTION SIGN LINT FAILED"
fi
exit "$fail"
