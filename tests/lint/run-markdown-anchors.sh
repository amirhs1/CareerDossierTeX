#!/usr/bin/env bash
# run-markdown-anchors.sh — every Markdown anchor link resolves (issue #407)
#
# The documentation set navigates by cross-document links, and #259 made that
# load-bearing: `docs/API.md` and `docs/MIGRATION.md` now point at
# `docs/ARCHITECTURE.md` for mechanisms they used to restate. A pointer that
# resolves to nothing is worse than the duplication it replaced — the reader
# lands at the top of a 2,200-line file with no derivation in sight.
#
# That failure was already in the tree when this was written, and had been since
# `v0.8.0` shipped. `CHANGELOG.md` linked three times to
# `docs/MIGRATION.md#080---unreleased`; the heading had become
# `## [0.8.0] - 2026-08-12`, whose anchor is `#080---2026-08-12`. The release
# renamed the heading, as a release must, and left three links behind. Nothing
# looked, so nothing said. Same shape as #400: a hand-maintained index of
# another file's headings with no assertion that it resolves.
#
# WHAT IT ASSERTS
#
# For every `](TARGET.md#anchor)` and every same-file `](#anchor)` in a tracked
# Markdown file, outside fenced code:
#
#   1. TARGET.md exists, resolved relative to the linking file's directory;
#   2. `anchor` is the anchor of some heading in TARGET.md.
#
# THE ANCHOR DERIVATION, AND WHY THIS ONE
#
# GitHub lowercases the heading text, drops everything that is not a letter,
# digit, space, hyphen, or underscore, and turns spaces into hyphens. The
# derivation here is that rule, with one deliberate narrowing: it strips ASCII
# punctuation by name, plus the two non-ASCII punctuation marks the headings in
# this repository actually contain (em dash and rightwards arrow), and keeps
# every other byte. That keeps `é` — `## Résumé class` is `#résumé-class`, and a
# whitelist of `[a-z0-9 _-]` would have made it `#rsum-class` and reported a
# working link as broken. Enumerated, not assumed: the only non-ASCII characters
# in any heading in the tree are `é`, `—`, and `→`.
#
# It is therefore not a general GitHub-compatible implementation and does not
# claim to be. It is good enough for the headings this repository writes, and
# the refutation is cheap and was run: against the tree as it stood it reported
# exactly the three known-broken `CHANGELOG.md` links and nothing else. If a
# heading ever uses punctuation this does not know, the lint reports a present
# anchor as missing — the #398 failure mode — and the fix is to teach the
# derivation, not to delete the check.
#
# Duplicate headings are not modelled. GitHub disambiguates repeats by appending
# `-1`, `-2`; no tracked file has two headings with the same text, so this
# reports that condition rather than guessing at it.
#
# It compiles nothing and reads Markdown, so it lives in the sub-second `lint`
# slot beside the option lint and the AGENTS.md reference lint, and runs on the
# TeX-free CI lint runner.
#
# Requirements: bash, awk, and git (for the tracked-file list). Run from
# anywhere. Portability: local `grep` is ugrep and CI's is GNU, local `awk` is
# the one-true-awk and CI's is gawk or mawk, so all parsing is awk and the
# regexes stay POSIX. It must run under bash, not zsh — zsh does not word-split
# unquoted expansions.
set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../.." && pwd)"
fixtures="$here/fixtures"
fail=0

# Output guards that answer "could not check" apart from "absent" (issue #398).
# shellcheck source=tests/lib/text.sh
. "$root/tests/lib/text.sh"

# ---------------------------------------------------------------------------
# One self-contained awk program: it scans the files it is given for links, and
# loads each link target's anchors on demand with getline. No temp files — the
# other lints here use none either, and mktemp is not writable under the
# repository's Bash sandbox.
#
# Emits `UNRESOLVED <file>:<line> <link> <why>` per failure and `CHECKED <n>`
# once. Exit 1 if any link was unresolved.

read -r -d '' awk_check <<'AWK'
function anchor(h,   s) {
  s = tolower(h)
  # Non-ASCII punctuation these headings actually use. Removed before the ASCII
  # pass because a byte-wise class cannot name them.
  gsub(/—/, "", s)
  gsub(/→/, "", s)
  # ASCII punctuation, by blacklist. A whitelist would eat `é`; see the header.
  gsub(/[][!"#$%&'"'"'()*+,.\/:;<=>?@^`{|}~\\]/, "", s)
  sub(/^ +/, "", s); sub(/ +$/, "", s)
  # One hyphen per space, NOT per run of spaces. Removing a `—` or a `→` leaves
  # the spaces that flanked it, and GitHub turns both into hyphens: `XeLaTeX →
  # LuaLaTeX` is `xelatex--lualatex`. A `gsub(/ +/, "-")` here collapsed those
  # to one and reported two working links in docs/MIGRATION.md as broken — the
  # #398 failure mode this lint's own header warns about, caught by running it
  # against the tree before trusting it.
  gsub(/ /, "-", s)
  return s
}

# Load one target file's anchors. Sets loaded[path] to 1 if it was readable,
# and -1 if it was not, so a missing file is distinguished from one with no
# headings rather than the two reading alike (issue #398).
function load(path,   line, h, fence, n) {
  if (path in loaded) return loaded[path]
  fence = 0; n = 0
  while ((getline line < path) > 0) {
    n++
    if (line ~ /^[ \t]*(```|~~~)/) { fence = !fence; continue }
    if (fence) continue
    if (line ~ /^#{1,6} /) {
      h = line
      sub(/^#+ +/, "", h)
      sub(/ +$/, "", h)
      have[path SUBSEP anchor(h)] = 1
    }
  }
  close(path)
  loaded[path] = (n > 0) ? 1 : -1
  return loaded[path]
}

function resolve(file, target,   dir, path) {
  if (target == "") return file
  dir = file
  if (sub(/\/[^\/]*$/, "", dir) == 0) dir = "."
  path = dir "/" target
  while (sub(/[^\/]+\/\.\.\//, "", path)) { }
  sub(/^\.\//, "", path)
  return path
}

FNR == 1 { fence = 0 }
/^[ \t]*(```|~~~)/ { fence = !fence; next }
fence { next }
{
  rest = $0
  # Inline code spans are examples, not pointers — the same reason fenced blocks
  # are skipped above. Documenting this lint in `docs/TESTING.md` and
  # `CHANGELOG.md` meant writing `](TARGET.md#anchor)` in prose, and without
  # this the lint failed on its own documentation. Link *text* may contain a
  # span; deleting it leaves the `](target)` half intact, which is all that is
  # matched below.
  gsub(/`[^`]*`/, " ", rest)
  while (match(rest, /\]\([^()#]*#[^()]+\)/)) {
    seg = substr(rest, RSTART + 2, RLENGTH - 3)   # strip "](" and ")"
    rest = substr(rest, RSTART + RLENGTH)
    hash = index(seg, "#")
    target = substr(seg, 1, hash - 1)
    frag = substr(seg, hash + 1)
    # External links are not ours to resolve, and `make links` owns URLs.
    if (target ~ /:\/\//) continue
    # Only Markdown targets; the empty target is the same-file form.
    if (target != "" && target !~ /\.md$/) continue
    if (frag == "") continue

    checked++
    path = resolve(FILENAME, target)
    if (load(path) < 0) {
      printf "UNRESOLVED\t%s:%d\t%s#%s\tno such file, or it is empty: %s\n",
             FILENAME, FNR, target, frag, path
      bad = 1
      continue
    }
    if (!((path SUBSEP frag) in have)) {
      printf "UNRESOLVED\t%s:%d\t%s#%s\tno heading in %s derives that anchor\n",
             FILENAME, FNR, target, frag, path
      bad = 1
    }
  }
}
END {
  # Report how much was actually inspected, so "nothing matched" cannot read as
  # a pass (issue #398's lesson, applied to the scan rather than to a guard).
  printf "CHECKED\t%d\n", checked
  exit bad ? 1 : 0
}
AWK

# check_files <file>... — one line per unresolved link; returns 1 if any.
check_files() {
  awk "$awk_check" "$@"
}

# ---------------------------------------------------------------------------
# The tree.

echo "== every Markdown anchor link in the tree resolves =="

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
  checked="$(printf '%s\n' "$out" | awk -F'\t' '$1 == "CHECKED" { print $2 }')"
  if printf '%s\n' "$out" | awk -F'\t' '$1 == "NOLINKS" { exit 1 }'; then
    :
  else
    echo "  FAIL: ${#tracked[@]} Markdown files contain no anchor links at all."
    echo "        They contained dozens when this lint was written, so the link"
    echo "        parse has broken rather than the tree having changed."
    fail=1
    checked=0
  fi
  if [ "$rc" -ne 0 ]; then
    printf '%s\n' "$out" | awk -F'\t' '$1 == "UNRESOLVED" {
      printf "  FAIL: %s links to %s\n        -> %s\n", $2, $3, $4 }'
    fail=1
  fi
  [ -n "${checked:-}" ] && [ "$checked" != "0" ] &&
    echo "  $checked anchor links checked across ${#tracked[@]} files"
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

self_check anchorfixture-resolvable.md   "OK"
self_check anchorfixture-bad-anchor.md   "no heading in"
self_check anchorfixture-bad-file.md     "no such file"
self_check anchorfixture-same-file.md    "OK"
self_check anchorfixture-fenced.md       "OK"
self_check anchorfixture-collapse.md     "OK"
self_check anchorfixture-inline-code.md  "OK"

echo
if [ "$fail" -eq 0 ]; then
  echo "MARKDOWN ANCHOR LINT PASSED"
else
  echo "MARKDOWN ANCHOR LINT FAILED"
fi
exit "$fail"
