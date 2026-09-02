#!/usr/bin/env bash
# run-prose-pointers.sh — every prose section pointer resolves (issue #559)
#
# This instruction set navigates by two different cross-reference forms, and
# only one of them was checked. `tests/lint/run-markdown-anchors.sh` resolves
# the Markdown link form, `[text](file.md#anchor)`. The form the agent contract
# actually uses for rules is prose:
#
#   `.agents/skills/project-metadata/reference.md` ("Verification")
#
# Nothing looked at those. `AGENTS.md` "Precedence" requires every rule to have
# exactly one home and every other mention to be a pointer, so the count of
# these grows with how well that rule is followed — 35 resolutions across 34
# pointers when this was written.
#
# The failure it catches is silent in the worst way: renaming a heading is a
# normal edit, the pointer elsewhere still reads correctly in review, `make
# lint` stays green, and the reader who follows it finds no such section. PR
# #557 did exactly this — it renamed `Verification` to `The four PR-only
# read-back items` in one file while other files pointed at it — and in the same
# PR introduced four pointers whose *paths* resolved to nothing. All four were
# caught only because a throwaway checker was written by hand that day; nothing
# in the tree would have said a word.
#
# WHAT IT ASSERTS
#
# For every `` `PATH.md` ("Section Name") `` in a tracked Markdown file, outside
# fenced code:
#
#   1. PATH.md exists — resolved against the repository root, then against the
#      citing file's own directory;
#   2. every quoted name in that parenthetical is a heading in PATH.md.
#
# WHY "EVERY QUOTED NAME", NOT "THE NAME"
#
# One parenthetical can carry more than one:
#
#   `…/project-metadata/reference.md` ("Project field values" and "Verification")
#
# That is 1 pointer and 2 resolutions. The hand-written checker that motivated
# this issue read only the first, so the second was unchecked while the run
# reported "34 | bad: 0". A count of pointers is not a count of what was
# verified, and this lint reports the resolution count for that reason.
#
# WHY IT FLATTENS BEFORE IT PARSES
#
# The same trap `run-agents-references.sh` documents, in a second place. These
# files wrap at 80 columns, so a pointer straddles a newline — the path on one
# line and `("Name")` on the next, or the name itself split. A line-based scan
# misses those entirely and reports a clean run over a subset. So each file is
# flattened to one line before matching, with a line index kept alongside so a
# failure still names the line the pointer starts on.
#
# Each line is trimmed before it is joined. Without that, a name split across
# the wrap flattens to "Releases and   phases" — three spaces where the source
# has one — which is absent from the target under a string compare and reported
# as a break that is not one. It produced two such false failures before the
# trim was added.
#
# WHY IT PARSES THE PARENTHETICAL BY HAND
#
# The obvious implementation is one regex for the whole pointer:
#
#   /`[^`]+\.md` *\([^)]*"[^"]*"[^)]*\)/
#
# It is wrong here, and not in a way that shows up on a small test. The local
# awk (one-true-awk 20200816, the version macOS ships) evaluates it as spanning
# far past the closing parenthesis, through text that contains `)` characters
# the negated class forbids. Reduced to 74 characters it still reproduces:
#
#   s = "`docs/A.md` (\"Name\") is the map, short \"q\" and then (rule 6) later."
#   match(s, /`[^`]+\.md` *\([^)]*"[^"]*"[^)]*\)/)   # RLENGTH 65, should be 20
#
# On the real tree that regex found 22 pointers where there are 34, attributed
# section names to files that do not cite them, and produced a page of failures
# for a tree that is clean. Not a subtle miscount: wrong in both directions.
#
# Whether gawk and mawk agree is UNTESTED — neither is installed here, and CI
# has one of them, not this one. That is precisely why this does not depend on
# the answer. The path is matched with a single bracket class and one
# quantifier, which is verified to behave; the parenthetical is then delimited
# with index() and substr(), and the quoted names inside it likewise. No
# construct whose evaluation differed is used at all, so local and CI cannot
# disagree about what this lint sees.
#
# WHY BOTH PATH RESOLUTIONS
#
# Both forms are in use and both are correct. A skill's `SKILL.md` points at its
# own `reference.md` by bare name (33 of 34), which is only meaningful relative
# to the citing file; cross-tree pointers are written from the repository root.
# Resolving root-first and falling back to sibling accepts both. This is not
# cosmetic: the four breaks in #557 were sibling-relative paths written from a
# directory that did not contain the target, which is the one combination
# neither rule accepts.
#
# It compiles nothing and reads Markdown, so it lives in the sub-second `lint`
# slot beside the anchor lint, and runs on the TeX-free CI lint runner.
#
# Requirements: bash, awk, and git (for the tracked-file list). Run from
# anywhere. Portability: local `grep` is ugrep and CI's is GNU, local `awk` is
# the one-true-awk and CI's is gawk or mawk, so all parsing is awk and the
# regexes stay POSIX — no ENDFILE, no gensub, no length(array). It must run
# under bash, not zsh — zsh does not word-split unquoted expansions.
set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../.." && pwd)"
fixtures="$here/fixtures"
fail=0

# Output guards that answer "could not check" apart from "absent" (issue #398).
# shellcheck source=tests/lib/text.sh
. "$root/tests/lib/text.sh"

# ---------------------------------------------------------------------------
# One self-contained awk program. It buffers each file, flattens it, scans for
# pointers, and loads each target's headings on demand with getline. No temp
# files — mktemp is not writable under the repository's Bash sandbox.
#
# Emits `UNRESOLVED <file>:<line> <pointer> <why>` per failure, `CHECKED <n>`
# (resolutions) and `POINTERS <n>` once. Exit 1 if anything was unresolved.

read -r -d '' awk_check <<'AWK'
function load_headings(path,   line, h, seen) {
  if (path in loaded) return loaded[path]
  loaded[path] = 0
  while ((getline line < path) > 0) {
    if (line ~ /^#+ /) {
      h = line
      sub(/^#+ +/, "", h)
      sub(/ +$/, "", h)
      have[path SUBSEP h] = 1
      loaded[path] = 1
    }
  }
  close(path)
  return loaded[path]
}

# Resolve a cited path: repository root first, then the citing file's directory.
function resolve(citing, target,   dir, cand) {
  cand = root "/" target
  if (isfile(cand)) return cand
  dir = citing
  sub(/\/[^\/]*$/, "", dir)
  cand = dir "/" target
  if (isfile(cand)) return cand
  return ""
}

function isfile(p,   line, rc) {
  if (p in filecache) return filecache[p]
  rc = ((getline line < p) >= 0)
  close(p)
  filecache[p] = rc
  return rc
}

function lineof(off,   i) {
  for (i = nlines; i >= 1; i--)
    if (start[i] <= off) return lineno[i]
  return 1
}

function flush_file(   rest, base, path, names, n, i, tgt, nm, ms, ml,
                     after, cp, paren) {
  if (curfile == "") return
  rest = buf
  base = 0
  # One SIMPLE regex for the path, then index()/substr() for everything else.
  # See the header: the obvious single regex for the whole pointer is
  # mis-evaluated by the local awk, so the parenthetical is delimited by hand.
  while (match(rest, /`[^`]+\.md`/)) {
    ms = RSTART
    ml = RLENGTH
    path = substr(rest, ms + 1, ml - 2)
    after = substr(rest, ms + ml)
    sub(/^ +/, "", after)
    if (substr(after, 1, 1) != "(") { base += ms + ml - 1; rest = substr(rest, ms + ml); continue }
    cp = index(after, ")")
    if (cp == 0) { base += ms + ml - 1; rest = substr(rest, ms + ml); continue }
    paren = substr(after, 2, cp - 2)
    n = split_quoted(paren, names)
    if (n == 0) { base += ms + ml - 1; rest = substr(rest, ms + ml); continue }

    pointers++
    tgt = resolve(curfile, path)
    if (tgt == "") {
      printf "UNRESOLVED\t%s:%d\t%s\tno such file, from the root or from %s/\n",
             curfile, lineof(base + ms), path, dirof(curfile)
      bad = 1
    } else if (!load_headings(tgt)) {
      printf "UNRESOLVED\t%s:%d\t%s\ttarget has no headings at all\n",
             curfile, lineof(base + ms), path
      bad = 1
    }
    for (i = 1; i <= n; i++) {
      nm = names[i]
      checked++
      if (tgt != "" && !((tgt SUBSEP nm) in have)) {
        printf "UNRESOLVED\t%s:%d\t%s (\"%s\")\tno heading of that name in %s\n",
               curfile, lineof(base + ms), path, nm, path
        bad = 1
      }
    }
    base += ms + ml - 1
    rest = substr(rest, ms + ml)
  }
  curfile = ""
  buf = ""
  nlines = 0
}

function dirof(p,   d) { d = p; sub(/\/[^\/]*$/, "", d); return d }

# The quoted names inside a pointer's parenthetical. The path itself is
# backtick-delimited, never quote-delimited, so it cannot be picked up here.
# The quoted names in a parenthetical, by hand rather than by regex, for the
# same reason as above. The path is backtick-delimited and is not passed in
# here, so it cannot be picked up as a name.
function split_quoted(paren, out,   n, i, a, b, q) {
  n = 0
  i = 1
  while (1) {
    a = index(substr(paren, i), "\"")
    if (a == 0) break
    a = i + a - 1
    b = index(substr(paren, a + 1), "\"")
    if (b == 0) break
    b = a + b
    q = substr(paren, a + 1, b - a - 1)
    if (q != "") out[++n] = q
    i = b + 1
  }
  return n
}

BEGIN { FS = "\n"; curfile = ""; buf = ""; nlines = 0; fence = 0 }

FILENAME != curfile { flush_file(); curfile = FILENAME; fence = 0 }

{
  line = $0
  # Fenced code is illustration, not a pointer. Blank the line but keep it, so
  # the line index stays aligned with the source.
  if (line ~ /^ *(```|~~~)/) { fence = !fence; line = "" }
  else if (fence) line = ""
  # Trim before joining. A pointer that wraps must flatten to exactly one space,
  # or a section name split across the wrap becomes "Releases and   phases" —
  # present in the target, absent under a string compare, and reported as a
  # break that is not one. Measured: this produced two spurious failures before
  # the trim was added.
  sub(/^[ \t]+/, "", line)
  sub(/[ \t]+$/, "", line)
  nlines++
  lineno[nlines] = FNR
  start[nlines] = length(buf) + 1
  buf = buf line " "
}

END {
  flush_file()
  printf "POINTERS\t%d\n", pointers
  printf "CHECKED\t%d\n", checked
  exit bad ? 1 : 0
}
AWK

# check_files <file>... — one line per unresolved pointer; returns 1 if any.
check_files() {
  awk -v root="$root" "$awk_check" "$@"
}

# ---------------------------------------------------------------------------
# The tree.

echo "== every prose section pointer in the tree resolves =="

tracked=()
while IFS= read -r f; do
  case "$f" in
    tests/lint/fixtures/*) continue ;;   # deliberately broken; see below
  esac
  [ -f "$root/$f" ] && tracked+=("$root/$f")
done <<EOF
$(cd "$root" && git ls-files '*.md')
EOF

if [ "${#tracked[@]}" -eq 0 ]; then
  echo "  FAIL: no tracked Markdown files found. Either this is not a checkout"
  echo "        or the file list broke; the lint would otherwise assert nothing."
  fail=1
else
  out="$(cd "$root" && check_files "${tracked[@]}")"
  rc=$?
  pointers="$(printf '%s\n' "$out" | awk -F'\t' '$1 == "POINTERS" { print $2 }')"
  checked="$(printf '%s\n' "$out" | awk -F'\t' '$1 == "CHECKED" { print $2 }')"
  if [ "${pointers:-0}" -eq 0 ]; then
    echo "  FAIL: ${#tracked[@]} Markdown files contain no prose section pointers"
    echo "        at all. There were 34 when this lint was written, so the parse"
    echo "        has broken rather than the tree having changed."
    fail=1
  fi
  if [ "$rc" -ne 0 ]; then
    printf '%s\n' "$out" | awk -F'\t' '$1 == "UNRESOLVED" {
      printf "  FAIL: %s points at %s\n        -> %s\n", $2, $3, $4 }'
    fail=1
  fi
  [ "${pointers:-0}" -gt 0 ] &&
    echo "  $checked resolutions across $pointers pointers in ${#tracked[@]} files"
fi

# ---------------------------------------------------------------------------
# Fixtures. Each pins one verdict, so a lint that stopped detecting anything
# fails here rather than passing everything.

echo
echo "== fixtures (the lint's own failure modes) =="
self_check() {
  local fixture="$1" expected="$2" out rc
  out="$(cd "$fixtures" && check_files "$fixtures/$fixture")"
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
  # Issue #398: read three states, not two. A check that could not run is not a
  # report about the lint's message.
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

self_check pointerfixture-resolvable.md   "OK"
self_check pointerfixture-bad-file.md     "no such file"
self_check pointerfixture-bad-heading.md  "no heading of that name"
self_check pointerfixture-wrapped.md      "OK"
self_check pointerfixture-sibling.md      "OK"
self_check pointerfixture-fenced.md       "OK"
self_check pointerfixture-second-name.md  "no heading of that name"

echo
if [ "$fail" -eq 0 ]; then
  echo "PROSE POINTER LINT PASSED"
else
  echo "PROSE POINTER LINT FAILED"
fi
exit "$fail"
