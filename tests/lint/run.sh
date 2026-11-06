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
# Issue #266 moved the options every class shares into two generators in
# careerdossier-base.sty, \__cdossier_base_declare_shared_options:nnn and
# \__cdossier_base_declare_record_options:nnn. Their `.choices:nn' keys are
# templates: the module is the parameter #1, filled in by each call, so in a
# generator body (1)-(3) are checked with { #1 } as the module. Each call in a
# class,
#
#   \__cdossier_base_declare_shared_options:nn { <module> } { <key path> }
#
# then counts as declaring every key of that generator in that class, and must
#
#   4. name the module the calling file's name implies,
#   5. name the key path the file's own \ProcessKeysOptions processes,
#   6. name a generator that exists, and
#   7. not sit beside a hand-written declaration of a key it already declares.
#
# A generated option still has a second declaration in the package that owns
# its behaviour, by design (#266, "Non-goals"), so the two value lists can
# drift. The last check compares them: for each generated key, the generator's
# accepted values must equal the owning package's, in the same order.
#
# Every public choice-valued option is in scope. careerdossier-statement's
# `type' was the one exception when this lint landed, because it was hand-rolled
# with \str_case:nnF rather than .choices:nn; it is an ordinary choice
# list, so a choice option declared any other way is now a thing to convert
# rather than a shape the lint has to learn.
#
# The lint parses text; it runs no LaTeX and needs no TeX installation. It ends
# by running itself against tests/lint/fixtures/, which hold one complete option
# and deliberately incomplete ones, a generator with complete and defective
# calls, and an owning package that agrees with it and one that does not, so a
# lint that had stopped detecting anything would fail here rather than pass
# everything.
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

# The file that defines the shared-option generators. The self-check points it
# at a fixture generator instead.
gen_home="$root/careerdossier-base.sty"

# Emits one tab-separated record per relevant line:
#
#   CHOICE   <block> <key> <generator>
#   HANDLER  <block> <key> <reported-module> <reported-message>
#
# <block> counts \keys_define:nn openings, so a handler is credited to the key
# only when the two sit in the same block. A handler whose \msg_error could not
# be found within three lines reports `-' for both names. <generator> names the
# \__cdossier_base_declare_<generator>_options:nnn body a key sits in, or is
# `-' outside one; the body ends where its braces balance.
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
BEGIN { block = 0; pend = 0; gen = "-"; depth = 0; opened = 0 }
{
  line = trim($0)
  if (line ~ /^%/) next
  if (match(line, /\\cs_new_protected:Npn[ \t]*\\__cdossier_base_declare_[a-z]+_options:nnn/)) {
    gen = substr(line, RSTART, RLENGTH)
    sub(/^.*\\__cdossier_base_declare_/, "", gen)
    sub(/_options:nnn$/, "", gen)
    depth = 0; opened = 0
  }
  if (line ~ /\\keys_define:nn/) block++
  if (pend > 0 && !grab(line)) { if (--pend == 0) emit("-", "-") }
  if (match(line, /^[A-Za-z][A-Za-z0-9]*[ \t]+\.choices:nn/)) {
    key = line
    sub(/[ \t]+\.choices:nn.*$/, "", key)
    printf "CHOICE\t%d\t%s\t%s\n", block, key, gen
  } else if (match(line, /^[A-Za-z][A-Za-z0-9]*[ \t]*\/[ \t]*unknown[ \t]+\.code:n/)) {
    pkey = line
    sub(/[ \t]*\/.*$/, "", pkey)
    pblock = block
    pend = 3
    grab(line)
  }
  if (gen != "-") {
    t = line; o = gsub(/[{]/, "", t)
    t = line; c = gsub(/[}]/, "", t)
    depth += o - c
    if (o > 0) opened = 1
    if (opened && depth <= 0) gen = "-"
  }
}
END { if (pend > 0) emit("-", "-") }
AWK

# The keys a generator in $gen_home declares, one per line.
generator_keys() {
  awk "$awk_scan" "$gen_home" \
    | awk -F'\t' -v g="$1" '$1 == "CHOICE" && $4 == g { print $3 }'
}

# Checks one file. Prints one status line per choice-valued option, plus a
# detail line naming the missing half for each failure. Returns 1 on any
# failure, 0 otherwise. The number of options a class or package declares,
# by hand or through a generator call, is left in $checked; generator
# templates are counted apart, in $templates.
checked=0
templates=0
lint_file() {
  local file="$1"
  local module records choices handler block key gen hmod hmsg mod_seen bad=0
  local expected note calls
  module="$(basename "$file")"
  module="${module%.*}"

  records="$(awk "$awk_scan" "$file")"
  choices="$(printf '%s\n' "$records" | grep '^CHOICE' || true)"

  # Comment lines are dropped before the file is flattened to one line: the
  # \msg_new: argument list may be wrapped, and the surrounding prose must not
  # be able to satisfy the check by merely describing it.
  local flat
  flat="$(grep -v '^[[:space:]]*%' "$file" | tr '\n' ' ' | tr -s ' ')"

  # A call takes two braced arguments; the generator definitions themselves
  # take #1#2, and the wrappers call the :nnn form, so neither matches.
  calls="$(printf '%s' "$flat" \
    | grep -oE '\\__cdossier_base_declare_[a-z]+_options:nn[[:space:]]*[{][^{}]*[}][[:space:]]*[{][^{}]*[}]' \
    || true)"

  [ -n "$choices" ] || [ -n "$calls" ] || return 0

  while IFS="$(printf '\t')" read -r _ block key gen; do
    [ -n "$key" ] || continue
    if [ "$gen" = "-" ]; then
      expected="$module"
      note=""
      checked=$((checked + 1))
    else
      expected="#1"
      note=" (template, $gen generator)"
      templates=$((templates + 1))
    fi

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
      detail="add '$key / unknown .code:n' to the \\keys_define:nn block, reporting { $expected } { unknown-$key }"
    elif [ -z "$mod_seen" ]; then
      status="MISSING MESSAGE"
      detail="add \\msg_new:nnnn { $expected } { unknown-$key } naming the accepted values"
    elif [ "$mod_seen" != "$expected" ]; then
      status="WRONG MODULE"
      detail="\\msg_new:nnnn declares { $mod_seen }; in $(basename "$file") it must be { $expected }"
    elif [ "$hmod" != "$expected" ] || [ "$hmsg" != "unknown-$key" ]; then
      status="WRONG TARGET"
      detail="the '$key / unknown' handler reports { $hmod } { $hmsg }; it must report { $expected } { unknown-$key }"
    fi

    printf '  %-28s %-10s %s\n' "$module" "$key" "$status$note"
    if [ -n "$detail" ]; then
      printf '    -> %s\n' "$detail"
      bad=1
    fi
  done <<EOF
$choices
EOF

  # Generator calls (issue #266). The call's status applies to every key the
  # generator declares, so each is reported and counted as this file's own.
  local call cmod cpath ppath keys literal
  ppath="$(printf '%s' "$flat" \
    | grep -oE '\\ProcessKeysOptions[[:space:]]*[{][^{}]*[}]' | head -1 \
    | sed -E 's/^[^{]*[{]//; s/[}]$//' | tr -d ' ')"
  literal="$(printf '%s\n' "$choices" | awk -F'\t' '$4 == "-" { print $3 }')"
  while IFS= read -r call; do
    [ -n "$call" ] || continue
    gen="$(printf '%s' "$call" | sed -E 's/^.*_declare_([a-z]+)_options.*$/\1/')"
    cmod="$(printf '%s' "$call" | awk -F'[{}]' '{ print $2 }' | tr -d ' ')"
    cpath="$(printf '%s' "$call" | awk -F'[{}]' '{ print $4 }' | tr -d ' ')"
    keys="$(generator_keys "$gen")"

    local status="OK" detail=""
    if [ -z "$keys" ]; then
      status="UNKNOWN GENERATOR"
      detail="no \\__cdossier_base_declare_${gen}_options:nnn in $(basename "$gen_home") declares a choice-valued key"
      keys="($gen)"
    elif [ "$cmod" != "$module" ]; then
      status="WRONG MODULE"
      detail="the $gen generator call names { $cmod }; in $(basename "$file") it must be { $module }"
    elif [ "$cpath" != "$ppath" ]; then
      status="WRONG PATH"
      detail="the $gen generator call names { $cpath }; \\ProcessKeysOptions processes { ${ppath:-nothing} }"
    fi

    while IFS= read -r key; do
      local kstatus="$status" kdetail="$detail"
      if [ "$kstatus" = "OK" ]; then
        # $literal holds this file's hand-written keys and is empty when there
        # are none, which is an answer (no duplicate) rather than unavailable
        # text; any other non-match is the same answer.
        text_contains_line "$literal" "$key"
        case "$?" in
          0)
            kstatus="DUPLICATE"
            kdetail="'$key' is declared by hand and by the $gen generator; delete the hand-written one"
            ;;
        esac
      fi
      checked=$((checked + 1))
      printf '  %-28s %-10s %s\n' "$module" "$key" "$kstatus (via $gen generator)"
      if [ -n "$kdetail" ]; then
        printf '    -> %s\n' "$kdetail"
        bad=1
      fi
    done <<EOF
$keys
EOF
  done <<EOF
$calls
EOF

  return "$bad"
}

# A key's accepted values in a file, as `a,b,c': the first brace group after
# `<key> .choices:nn ='. Empty if the file does not declare the key.
value_list() {
  grep -v '^[[:space:]]*%' "$1" | tr '\n' ' ' \
    | grep -oE "(^|[^A-Za-z0-9])$2[[:space:]]+[.]choices:nn[[:space:]]*=[[:space:]]*[{][^{}]*[}]" \
    | head -1 | sed -E 's/^.*=[[:space:]]*[{]//; s/[}]$//' | tr -d ' '
}

# Compares one generated key's value list against its owning package's.
parity_check() {
  local key="$1" owner="$2" mine theirs
  mine="$(value_list "$gen_home" "$key")"
  theirs="$(value_list "$owner" "$key")"
  if [ -z "$mine" ] || [ -z "$theirs" ]; then
    printf '  %-10s %-30s %s\n' "$key" "$(basename "$owner")" "NOT FOUND"
    printf '    -> %s: { %s }; %s: { %s }\n' \
      "$(basename "$gen_home")" "${mine:-absent}" "$(basename "$owner")" "${theirs:-absent}"
    return 1
  elif [ "$mine" != "$theirs" ]; then
    printf '  %-10s %-30s %s\n' "$key" "$(basename "$owner")" "VALUE LISTS DIFFER"
    printf '    -> %s accepts { %s }; %s accepts { %s }\n' \
      "$(basename "$gen_home")" "$mine" "$(basename "$owner")" "$theirs"
    return 1
  fi
  printf '  %-10s %-30s %s\n' "$key" "$(basename "$owner")" "PARITY OK { $mine }"
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
  echo "  $checked choice-valued options checked, and $templates generator templates"
fi

# The package that owns each generated option's behaviour (issue #266, the
# table under "Problem"). `paper' has none: the classes resolve it themselves,
# so the generator is its only declaration.
echo
echo "== generator value lists against the owning packages =="
owners="fontsize careerdossier-tokens.sty
margin careerdossier-tokens.sty
paper -
bodyfont careerdossier-typography.sty
medium careerdossier-components.sty
muted careerdossier-components.sty
entrymeta careerdossier-components.sty"

generated="$(awk "$awk_scan" "$gen_home" \
  | awk -F'\t' '$1 == "CHOICE" && $4 != "-" { print $3 }' | sort)"
listed="$(printf '%s\n' "$owners" | cut -d' ' -f1 | sort)"
if [ -z "$generated" ]; then
  echo "  NO GENERATED OPTIONS FOUND in $(basename "$gen_home")"
  fail=1
elif [ "$generated" != "$listed" ]; then
  echo "  OWNER TABLE OUT OF DATE: the generators declare"
  printf '%s\n' "$generated" | tr '\n' ' ' | sed 's/^/    /'; echo
  echo "    but this lint lists owners for"
  printf '%s\n' "$listed" | tr '\n' ' ' | sed 's/^/    /'; echo
  fail=1
fi
while read -r key owner; do
  if [ "$owner" = "-" ]; then
    others="$(for f in "$root"/*.sty; do
      [ "$f" = "$gen_home" ] && continue
      [ -n "$(value_list "$f" "$key")" ] && basename "$f"
    done)"
    if [ -n "$others" ]; then
      printf '  %-10s %-30s %s\n' "$key" "$others" "OWNER NOT LISTED"
      echo "    -> name the owning package in this lint's owner table"
      fail=1
    else
      printf '  %-10s %-30s %s\n' "$key" "-" "no owning package; the generator is its only declaration"
    fi
  else
    parity_check "$key" "$root/$owner" || fail=1
  fi
done <<EOF
$owners
EOF

# Self-check. Each fixture pins one verdict, so a lint that stopped detecting a
# missing half -- or started rejecting a complete option -- fails here.
echo
echo "== fixtures (the lint's own failure modes) =="
self_check() {
  local fixture="$1" expected="$2" out rc
  if [ "${3:-}" = "parity" ]; then
    out="$(gen_home="$fixtures/lintfixture-generator.sty"
      parity_check size "$fixtures/$fixture")"
  else
    out="$(checked=0; gen_home="$fixtures/lintfixture-generator.sty"
      lint_file "$fixtures/$fixture")"
  fi
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
self_check lintfixture-generator.sty               "OK"
self_check lintfixture-template-wrong-module.sty   "WRONG MODULE"
self_check lintfixture-call-ok.sty                 "OK"
self_check lintfixture-call-wrong-module.sty       "WRONG MODULE"
self_check lintfixture-call-wrong-path.sty         "WRONG PATH"
self_check lintfixture-call-unknown.sty            "UNKNOWN GENERATOR"
self_check lintfixture-call-duplicate.sty          "DUPLICATE"
self_check lintfixture-parity-ok.sty               "OK"                 parity
self_check lintfixture-parity-drift.sty            "VALUE LISTS DIFFER" parity

echo
if [ "$fail" -eq 0 ]; then
  echo "OPTION LINT PASSED"
else
  echo "OPTION LINT FAILED"
fi
exit "$fail"
