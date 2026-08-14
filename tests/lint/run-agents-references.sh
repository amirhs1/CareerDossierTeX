#!/usr/bin/env bash
# run-agents-references.sh — the AGENTS.md cross-reference contract
#
# `AGENTS.md` "Build and test" reproduces none of the test documentation. It
# points at it instead, by naming sections of `CONTRIBUTING.md` and
# `docs/TESTING.md` in quotation marks. That is the right shape — one home per
# rule — but it is a hand-maintained index of another file's headings, and this
# repository already knows what happens to those. `CONTRIBUTING.md` "Local
# builds" says so itself, about a different list:
#
#   A hand-maintained copy of either will drift, and a drifted copy is how the
#   `annotations` suite came to be omitted from a run that was then reported
#   clean.
#
# It then happened to the sentence pointing at that chapter. Between 2026-08-12
# and 2026-08-14 the running chapter went from two sections to four — PR #389
# added "The same suite, faster, before a push" and PR #397 added "Running one
# suite's fixtures concurrently" — and neither updated `AGENTS.md`, which went on
# claiming there were two. Both omissions were the `check-parallel` entry points
# that week of work had just built, so the always-loaded core pointed away from
# the very thing an agent needed to find. Twice in two days, by two changes,
# neither noticed by review. That is a missing assertion, not carelessness
# (issue #400).
#
# WHAT IT ASSERTS
#
# Two directions, because the two failures are different and only one of them is
# what already happened:
#
#   1. RESOLVABLE — every section name `AGENTS.md` quotes in "Build and test"
#      exists as a heading in `CONTRIBUTING.md` or `docs/TESTING.md`. Catches a
#      rename or a deletion on the far side, where the pointer silently starts
#      naming nothing.
#   2. COMPLETE — every `###` section of `CONTRIBUTING.md`'s "Local builds"
#      chapter is named in `AGENTS.md` "Build and test". Catches an *addition*,
#      which is the bug above: nothing breaks, no run fails, the index is just
#      quietly short.
#
# Direction 2 is deliberately NOT applied to `docs/TESTING.md`. `AGENTS.md`
# names six of its sections and ignores the rest on purpose — the reading map
# exists to make reading selective — so "every TESTING.md heading is named"
# would be false by design. Asserting it would force the index to grow into the
# copy this file exists to prevent.
#
# WHY IT NORMALISES BEFORE IT PARSES
#
# Measured while writing this, and the reason the obvious implementation is
# wrong: `AGENTS.md` wraps at 80 columns, so a quoted section name straddles a
# newline. A line-based `grep -o '"[^"]*"'` reports "Match the test to the
# module" and "Scoping a suite while you iterate" as ABSENT — they are not, they
# are merely split — and it invents a candidate out of the prose *between* two
# halves of different quotes:
#
#   " for which kind of test a concern takes, "
#
# So it fails on names that are present and demands a heading for text that is
# not a name: wrong in both directions at once, and green-looking in neither.
# The section is therefore collapsed to a single line before any quote is read.
#
# THE ONE CONSTRAINT THIS IMPOSES
#
# Direction 1 treats *every* quoted string in "Build and test" as a section
# name. All of them are today. A future author who quotes a phrase there that is
# not a heading gets a failure naming it, and should either rephrase or stop
# quoting. That is a real constraint on one short section's prose, accepted
# deliberately: the alternative is a hand-maintained list of which quotes count,
# which is another copy of the thing that drifts.
#
# It compiles nothing and reads three Markdown files, so it lives in the
# sub-second `lint` slot beside the option lint and the fixture-selection
# contract, and runs on the TeX-free CI lint runner.
#
# Requirements: bash and awk. Run from anywhere.
set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../.." && pwd)"
fail=0

agents="$root/AGENTS.md"
contributing="$root/CONTRIBUTING.md"
testing="$root/docs/TESTING.md"

for f in "$agents" "$contributing" "$testing"; do
  if [ ! -f "$f" ]; then
    echo "MISSING required file: $f"
    exit 1
  fi
done

# The "Build and test" section of AGENTS.md, collapsed to one line. See the
# header: without the collapse this parse is wrong in two directions at once.
section="$(awk '/^## Build and test/{f=1;next} /^## /{f=0} f' "$agents" \
            | tr '\n' ' ' | tr -s ' ')"

if [ -z "$section" ]; then
  echo "FAIL: AGENTS.md has no '## Build and test' section, or it is empty."
  echo "      This lint indexes that section; if it moved, repoint the lint."
  exit 1
fi

# Membership without a pipe into `grep -q`. The pipe form exits at its first
# match, hands the producer a SIGPIPE, and under `pipefail` reports "not found"
# for something that is there — the same trap tests/lint/run-fixture-filter.sh
# documents, and the reason both files walk arrays instead.
quoted_names=()
while IFS= read -r name; do
  [ -n "$name" ] && quoted_names+=("$name")
done <<EOF
$(printf '%s' "$section" | grep -o '"[^"]*"' | sed 's/^"//; s/"$//')
EOF

section_names_agents() {
  local candidate
  for candidate in ${quoted_names[@]+"${quoted_names[@]}"}; do
    [ "$candidate" = "$1" ] && return 0
  done
  return 1
}

heading_exists() {
  # A heading at any depth, matched whole: `grep -F "# $1"` alone would let
  # "Local builds" match a heading called "Local builds and beyond".
  local file="$1" name="$2"
  awk -v want="$name" '
    /^#+ /{ h = $0; sub(/^#+ +/, "", h); sub(/ +$/, "", h); if (h == want) found = 1 }
    END { exit found ? 0 : 1 }' "$file"
}

# --------------------------------------------------------------------------
# Direction 1: every name AGENTS.md quotes resolves to a real heading.

echo "== every section AGENTS.md names exists =="
if [ "${#quoted_names[@]}" -eq 0 ]; then
  echo "  FAIL: AGENTS.md 'Build and test' quotes no section names at all."
  echo "        Either the section was rewritten or the parse broke; both need"
  echo "        a look, because this lint would otherwise assert nothing."
  fail=1
else
  for name in "${quoted_names[@]}"; do
    if heading_exists "$contributing" "$name"; then
      echo "  ok: \"$name\" -> CONTRIBUTING.md"
    elif heading_exists "$testing" "$name"; then
      echo "  ok: \"$name\" -> docs/TESTING.md"
    else
      echo "  FAIL: AGENTS.md names \"$name\", which is a heading in neither"
      echo "        CONTRIBUTING.md nor docs/TESTING.md. Either it was renamed"
      echo "        or removed there, or this is a quoted phrase that is not a"
      echo "        section name — see this script's header on that constraint."
      fail=1
    fi
  done
fi

# --------------------------------------------------------------------------
# Direction 2: every section of the running chapter is named. This is the one
# that already failed twice.

echo
echo "== every section of CONTRIBUTING.md's running chapter is named =="
running_sections=()
while IFS= read -r name; do
  [ -n "$name" ] && running_sections+=("$name")
done <<EOF
$(awk '/^## Local builds/{f=1} f && /^## /&& !/^## Local builds/{exit} f && /^### /{
         sub(/^### +/, ""); sub(/ +$/, ""); print }' "$contributing")
EOF

if [ "${#running_sections[@]}" -eq 0 ]; then
  echo "  FAIL: CONTRIBUTING.md's 'Local builds' chapter has no ### sections."
  echo "        It had three when this lint was written; if the chapter was"
  echo "        restructured, repoint the lint rather than deleting the check."
  fail=1
else
  for name in "${running_sections[@]}"; do
    if section_names_agents "$name"; then
      echo "  ok: \"$name\" is named in AGENTS.md"
    else
      echo "  FAIL: CONTRIBUTING.md has \"$name\" under 'Local builds', and"
      echo "        AGENTS.md 'Build and test' does not name it. An agent"
      echo "        reading only the always-loaded core cannot discover it."
      fail=1
    fi
  done
fi

echo
if [ "$fail" -ne 0 ]; then
  echo "AGENTS.md CROSS-REFERENCE CONTRACT BROKEN"
  exit 1
fi
echo "AGENTS.md CROSS-REFERENCE CONTRACT HELD"
