#!/usr/bin/env bash
# run.sh — CareerDossierTeX option lint (issue #233)
#
# Every choice-valued public option must name its accepted values when it is
# given one that is not accepted (issue #212). That takes two hand-written
# pieces, in two places in the same file:
#
#   \msg_new:nnnn { <module> } { unknown-<key> } { ... } { ... }
#   <key> / unknown .code:n =
#     { \msg_error:nnn { <module> } { unknown-<key> } {#1} } ,
#
# Nothing in LaTeX enforces the pairing. Omit the `<key> / unknown' sub-key and
# the option silently falls back to l3keys' stock "accepts only a fixed set of
# choices" error -- the exact regression #212 removed -- and no test fails,
# because every test asserts a message that *is* defined rather than the absence
# of one that is not. So this check runs the other way round: it derives the
# expected set from the source and asserts completeness.
#
# For each `<key> .choices:nn' in a root .cls/.sty it requires
#
#   1. a `<key> / unknown .code:n' entry in the same \keys_define:nn block,
#   2. a \msg_new:nnnn for { unknown-<key> } in the same file, and
#   3. that both name the module the filename implies.
#
# (3) is not redundant: a \msg_new:nnnn { careerdossier-resume } pasted into
# careerdossier-cv.cls would otherwise satisfy (2) while defining the message
# for the wrong module, and a handler pointing at another key's message would
# otherwise satisfy (1) while reporting the wrong accepted values.
#
# Every public choice-valued option is in scope. careerdossier-statement's
# `type' was the one exception when this lint landed, because it was hand-rolled
# with \str_case:nnF rather than .choices:nn; #236 made it an ordinary choice
# list, so a choice option declared any other way is now a thing to convert
# rather than a shape the lint has to learn.
#
# The lint parses text; it runs no LaTeX and needs no TeX installation. It ends
# by running itself against tests/lint/fixtures/, which hold one complete option
# and four deliberately incomplete ones, so a lint that had stopped detecting
# anything would fail here rather than pass everything.
#
# Requirements: bash and awk. Run from anywhere.
#
# Two portability notes, because this file is the only test that is pure text
# processing and so is the only one whose toolchain differs between the
# maintainer's machine and CI. Local `grep' is ugrep and CI's is GNU grep, and
# local `awk' is the one-true-awk while CI's is gawk or mawk; a brace is written
# `[{]' rather than `\{' throughout, which every one of them reads the same way.
# And this must run under bash, not zsh: zsh does not word-split unquoted
# parameter expansions, so a key list developed there collapses into one string.
set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../.." && pwd)"

# Output guards that answer "could not check" apart from "absent" (issue #398).
# shellcheck source=tests/lib/text.sh
. "$root/tests/lib/text.sh"

fixtures="$here/fixtures"

# Emits one tab-separated record per relevant line:
#
#   CHOICE   <block> <key>
#   HANDLER  <block> <key> <reported-module> <reported-message>
#
# <block> counts \keys_define:nn openings, so a handler is credited to the key
# only when the two sit in the same block. A handler whose \msg_error could not
# be found within three lines reports `-' for both names.
read -r -d '' awk_scan <<'AWK'
function trim(s) { sub(/^[ \t]+/, "", s); sub(/[ \t]+$/, "", s); return s }
function emit(mod, msg) {
  printf "HANDLER\t%d\t%s\t%s\t%s\n", pblock, pkey, mod, msg
  pend = 0
}
function grab(l,   seg, parts) {
  if (match(l, /\\msg_error:nn[a-z][ \t]*[{][^{}]*[}][ \t]*[{][^{}]*[}]/)) {
    seg = substr(l, RSTART, RLENGTH)
    split(seg, parts, /[{}]/)
    emit(trim(parts[2]), trim(parts[4]))
    return 1
  }
  return 0
}
BEGIN { block = 0; pend = 0 }
{
  line = trim($0)
  if (line ~ /^%/) next
  if (line ~ /\\keys_define:nn/) block++
  if (pend > 0 && !grab(line)) { if (--pend == 0) emit("-", "-") }
  if (match(line, /^[A-Za-z][A-Za-z0-9]*[ \t]+\.choices:nn/)) {
    key = line
    sub(/[ \t]+\.choices:nn.*$/, "", key)
    printf "CHOICE\t%d\t%s\n", block, key
  } else if (match(line, /^[A-Za-z][A-Za-z0-9]*[ \t]*\/[ \t]*unknown[ \t]+\.code:n/)) {
    pkey = line
    sub(/[ \t]*\/.*$/, "", pkey)
    pblock = block
    pend = 3
    grab(line)
  }
}
END { if (pend > 0) emit("-", "-") }
AWK

# Checks one file. Prints one status line per choice-valued option, plus a
# detail line naming the missing half for each failure. Returns 1 on any
# failure, 0 otherwise; the number of options seen is left in $checked.
checked=0
lint_file() {
  local file="$1"
  local module records choices handler block key hmod hmsg mod_seen bad=0
  module="$(basename "$file")"
  module="${module%.*}"

  records="$(awk "$awk_scan" "$file")"
  choices="$(printf '%s\n' "$records" | grep '^CHOICE' || true)"
  [ -n "$choices" ] || return 0

  # Comment lines are dropped before the file is flattened to one line: the
  # \msg_new: argument list may be wrapped, and the surrounding prose must not
  # be able to satisfy the check by merely describing it.
  local flat
  flat="$(grep -v '^[[:space:]]*%' "$file" | tr '\n' ' ' | tr -s ' ')"

  while IFS="$(printf '\t')" read -r _ block key; do
    [ -n "$key" ] || continue
    checked=$((checked + 1))

    handler="$(printf '%s\n' "$records" \
      | awk -F'\t' -v b="$block" -v k="$key" \
          '$1 == "HANDLER" && $2 == b && $3 == k { print; exit }')"
    hmod="$(printf '%s' "$handler" | cut -f4)"
    hmsg="$(printf '%s' "$handler" | cut -f5)"

    # Any module's message for this key, so a copy-pasted module name is
    # reported as the wrong module rather than as a missing message.
    mod_seen="$(printf '%s' "$flat" \
      | grep -oE '\\msg_new:nnnn[[:space:]]*[{][^{}]*[}][[:space:]]*[{][[:space:]]*unknown-'"$key"'[[:space:]]*[}]' \
      | head -1 \
      | sed -E 's/^[^{]*[{][[:space:]]*//; s/[[:space:]]*[}].*$//')"

    local status="OK" detail=""
    if [ -z "$handler" ]; then
      status="MISSING HANDLER"
      detail="add '$key / unknown .code:n' to the \\keys_define:nn block, reporting { $module } { unknown-$key }"
    elif [ -z "$mod_seen" ]; then
      status="MISSING MESSAGE"
      detail="add \\msg_new:nnnn { $module } { unknown-$key } naming the accepted values"
    elif [ "$mod_seen" != "$module" ]; then
      status="WRONG MODULE"
      detail="\\msg_new:nnnn declares { $mod_seen }; in $(basename "$file") it must be { $module }"
    elif [ "$hmod" != "$module" ] || [ "$hmsg" != "unknown-$key" ]; then
      status="WRONG TARGET"
      detail="the '$key / unknown' handler reports { $hmod } { $hmsg }; it must report { $module } { unknown-$key }"
    fi

    printf '  %-28s %-10s %s\n' "$module" "$key" "$status"
    if [ -n "$detail" ]; then
      printf '    -> %s\n' "$detail"
      bad=1
    fi
  done <<EOF
$choices
EOF

  return "$bad"
}

fail=0

echo "== choice-valued options in root .cls/.sty =="
for file in "$root"/*.cls "$root"/*.sty; do
  [ -f "$file" ] || continue
  lint_file "$file" || fail=1
done

if [ "$checked" -eq 0 ]; then
  echo "  NO CHOICE-VALUED OPTIONS FOUND — the lint is not matching anything"
  fail=1
else
  echo "  $checked choice-valued options checked"
fi

# Self-check. Each fixture pins one verdict, so a lint that stopped detecting a
# missing half -- or started rejecting a complete option -- fails here.
echo
echo "== fixtures (the lint's own failure modes) =="
self_check() {
  local fixture="$1" expected="$2" out rc
  out="$(checked=0; lint_file "$fixtures/$fixture")"
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
  else
    # Issue #398: read three states, not two. A check that could not run is not
    # a report about the lint's message.
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
  fi
}

self_check lintfixture-complete.sty        "OK"
self_check lintfixture-no-handler.sty      "MISSING HANDLER"
self_check lintfixture-no-message.sty      "MISSING MESSAGE"
self_check lintfixture-wrong-module.sty    "WRONG MODULE"
self_check lintfixture-wrong-target.sty    "WRONG TARGET"

echo
if [ "$fail" -eq 0 ]; then
  echo "OPTION LINT PASSED"
else
  echo "OPTION LINT FAILED"
fi
exit "$fail"
