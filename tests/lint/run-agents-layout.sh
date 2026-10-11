#!/usr/bin/env bash
# run-agents-layout.sh — AGENTS.md "Layout" lists manifest.txt's entries (issue #584)
#
# AGENTS.md, "Layout" copies manifest.txt's two groups, "The Work" and
# "Distributed with the Work", entry for entry, and says to change both in the
# same commit. Nothing held it to that: a file added to the Work and to
# manifest.txt but not to "Layout" passed every suite. This lint reads the paths
# of both groups from each file and fails on any difference, naming the group
# and the path: an entry missing from "Layout", one "Layout" has that
# manifest.txt does not, one in the other group, or the same entries in another
# order.
#
# Only paths are compared. The description beside each may be worded
# differently ("this file; defines the Work" in manifest.txt, "defines the
# Work" in "Layout"), and the "Repository only" group in "Layout" has no
# counterpart in manifest.txt.
#
# An entry is a line that starts with a path, followed by two or more spaces and
# a description; a continuation line starts with spaces. That shape, not the
# position under a group heading, is what tells an entry from the prose
# paragraph that opens manifest.txt's second group.
#
# Requirements: bash and awk. Portability as in the other lints: POSIX awk only,
# and bash, not zsh, which does not word-split unquoted expansions.
set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../.." && pwd)"
fixtures="$here/fixtures"
fail=0

# Output guards that answer "could not check" apart from "absent" (issue #398).
# shellcheck source=tests/lib/text.sh
. "$root/tests/lib/text.sh"

# entries <file> <kind>: one "<group><TAB><path>" line per entry of the two
# groups, in file order. kind is "manifest" (a group heading is underlined with
# dashes, and "Not distributed" ends the second group) or "agents" (the groups
# sit inside the fenced block of the "## Layout" section).
entries() {
  awk -v kind="$2" '
    function group(line) {
      return (line == "The Work" || line == "Distributed with the Work") ? line : ""
    }
    kind == "agents" && /^## / { inside = ($0 == "## Layout"); next }
    kind == "agents" && !inside { next }
    kind == "agents" && /^ *(```|~~~)/ { fenced = !fenced; g = ""; next }
    kind == "agents" && !fenced { next }
    {
      if (group($0) != "") { g = group($0); next }
      if ($0 == "Repository only" || $0 == "Not distributed") { g = ""; next }
      if (g != "" && $0 ~ /^[^ \t]+[ \t][ \t]+[^ \t]/) {
        split($0, f, /[ \t]+/)
        print g "\t" f[1]
      }
    }' "$1"
}

# compare <agents file> <manifest file>: prints one "DIFF" line per difference
# and a "COUNT" line; returns 1 on any difference or an empty parse.
compare() {
  local agents manifest
  agents="$(entries "$1" agents)"
  manifest="$(entries "$2" manifest)"
  # The count is reported, never tested, so it needs no three-state guard.
  printf 'COUNT\t%s\n' "$(printf '%s\n' "$manifest" | awk 'NF { n++ } END { print n + 0 }')"
  if [ -z "$manifest" ] || [ -z "$agents" ]; then
    printf 'DIFF\tno entries parsed from %s\n' "$([ -z "$manifest" ] && echo "$2" || echo "$1")"
    return 1
  fi
  [ "$agents" = "$manifest" ] && return 0
  awk -F '\t' '
    NR == FNR { m[$0] = 1; mo[++mn] = $0; next }
    { a[$0] = 1; ao[++an] = $0 }
    END {
      for (i = 1; i <= mn; i++) if (!(mo[i] in a)) {
        split(mo[i], x, "\t"); printf "DIFF\tmissing from \"Layout\": %s, under \"%s\"\n", x[2], x[1]; d = 1 }
      for (i = 1; i <= an; i++) if (!(ao[i] in m)) {
        split(ao[i], x, "\t"); printf "DIFF\tnot in manifest.txt: %s, under \"%s\"\n", x[2], x[1]; d = 1 }
      if (!d) print "DIFF\tsame entries in another order"
    }' <(printf '%s\n' "$manifest") <(printf '%s\n' "$agents")
  return 1
}

# ---------------------------------------------------------------------------
# The tree.

echo "== AGENTS.md \"Layout\" lists manifest.txt's two groups =="
out="$(compare "$root/AGENTS.md" "$root/manifest.txt")"
rc=$?
count="$(printf '%s\n' "$out" | awk -F'\t' '$1 == "COUNT" { print $2 }')"
if [ "$rc" -ne 0 ]; then
  printf '%s\n' "$out" | awk -F'\t' '$1 == "DIFF" { printf "  FAIL: %s\n", $2 }'
  echo "        Change AGENTS.md \"Layout\" and manifest.txt in the same commit."
  fail=1
else
  echo "  $count entries agree"
fi

# ---------------------------------------------------------------------------
# Fixtures. Each pins one verdict against one shared manifest, so a lint that
# stopped detecting anything fails here rather than passing everything.

echo
echo "== fixtures (the lint's own failure modes) =="
self_check() {
  local fixture="$1" expected="$2" out rc
  out="$(compare "$fixtures/$fixture" "$fixtures/layoutfixture-manifest.txt")"
  rc=$?
  if [ "$expected" = "OK" ]; then
    if [ "$rc" -ne 0 ]; then
      echo "  $fixture EXPECTED PASS but the lint reported:"
      printf '%s\n' "$out" | sed 's/^/    /'
      fail=1
    else
      echo "  $fixture accepted as intended"
    fi
    return
  fi
  if [ "$rc" -eq 0 ]; then
    echo "  $fixture EXPECTED FAILURE but the lint passed it"
    fail=1
    return
  fi
  text_contains "$out" "$expected"
  case "$?" in
    0) echo "  $fixture rejected as intended ($expected)" ;;
    1)
      echo "  $fixture FAILED for the wrong reason: expected '$expected', got:"
      printf '%s\n' "$out" | sed 's/^/    /'
      fail=1
      ;;
    *)
      echo "  $fixture PRODUCED NO CHECKABLE OUTPUT: '$expected' was never"
      echo "    looked for, so the rejection has not been shown to be the"
      echo "    intended one."
      fail=1
      ;;
  esac
}

self_check layoutfixture-ok.txt          "OK"
self_check layoutfixture-missing.txt     "missing from \"Layout\": LICENSE"
self_check layoutfixture-extra.txt       "not in manifest.txt: CLAUDE.md"
self_check layoutfixture-wrong-group.txt "missing from \"Layout\": README.md, under \"Distributed with the Work\""
self_check layoutfixture-order.txt       "same entries in another order"
self_check layoutfixture-empty.txt       "no entries parsed"

echo
if [ "$fail" -eq 0 ]; then
  echo "AGENTS LAYOUT LINT PASSED"
else
  echo "AGENTS LAYOUT LINT FAILED"
fi
exit "$fail"
