#!/usr/bin/env bash
# run-name-coverage.sh — every public name has a regression test (#694)
#
# A public name could land with no test, and no suite failed: the testing
# review of 2026-11-07 found the coverage by a one-off query, and nothing ran
# it again. run-manual-names.sh checks the manual against the Work; this lint
# checks the regression tests against the Work.
#
# WHAT IT ASSERTS
#
# Every public name defined in the Work appears in at least one regression
# test. The two sets, and why each is drawn where it is:
#
#   - A public name is a `CDossier' or `MakeCDossier' name (#265's policy),
#     with or without its backslash, outside a TeX comment in a `.sty' or
#     `.cls' file that manifest.txt lists under "The Work". It is the set
#     run-manual-names.sh's check (4) calls the names the Work defines, drawn
#     the same way, so the manual and the tests are held to one list. A name
#     the Work mentions only in a comment, such as one #242 made private, is
#     not public.
#   - A regression test is a tracked tests/regression/*.lvt, together with any
#     tests/regression/support/ file it \input's: the shared body
#     tokens-defaults.inc is part of the four tests that read it (#528), and an
#     include no test reads is part of none. A name counts as tested when it
#     appears there outside a TeX comment, so a test that only discusses a name
#     does not cover it.
#
# Appearing is the whole check. It cannot see whether the test asserts
# anything about the name, only that a test names it.
#
# THE BACKLOG
#
# tests/lint/name-coverage-backlog.txt declares the names that had no test
# when this lint landed. It may only shrink, and this lint makes that true, as
# run-fixture-headers.sh does for its own backlog (#534):
#
#   - an untested name that is not declared fails (UNTESTED NAME);
#   - an entry with no reason fails (NO REASON);
#   - an entry naming a name the Work no longer defines fails (STALE ENTRY);
#   - an entry whose name a test now covers fails (COVERED, DROP THE ENTRY),
#     so a new test shrinks the list in the same change;
#   - more entries than the `FROZEN AT <n>' line declares fails
#     (OVER THE FROZEN SIZE).
#
# THE LIST
#
# `run-name-coverage.sh --list' prints every name the lint checks, one per
# line with `tested' or `backlog', and exits. It is the authoritative list of
# public names: #710's audit takes its rows from it.
#
# THE CONTROLS
#
# Each verdict runs against tests/lint/fixtures/namefixture-* and a backlog
# under tests/lint/fixtures/ through the same check_coverage function the
# assertion uses, so a lint that stopped detecting anything fails here.
#
# Requirements: bash, awk, git, grep, and sort. Run from anywhere. No TeX.
# Run under bash, not zsh, which does not word-split the name lists.
set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../.." && pwd)"
backlog="$here/name-coverage-backlog.txt"

# Counts that answer "could not check" apart from zero (#398).
# shellcheck source=tests/lib/text.sh
. "$root/tests/lib/text.sh"
fail=0

# public_names <file>... -- every public name in the files outside TeX
# comments, one per line, sorted and unique. A comment runs from the first
# unescaped `%' to the end of the line, so `\%' starts none; the comment
# stripping is run-manual-names.sh's work_defined_names, unchanged.
public_names() {
  [ "$#" -gt 0 ] || return 0
  cat -- "$@" | awk '
    {
      line = $0
      out = ""
      while (length(line) > 0) {
        i = index(line, "%")
        if (i == 0) { out = out line; break }
        slashes = 0
        j = i - 1
        while (j >= 1 && substr(line, j, 1) == "\\") { slashes++; j-- }
        if (slashes % 2 == 1) {
          out = out substr(line, 1, i)
          line = substr(line, i + 1)
          continue
        }
        out = out substr(line, 1, i - 1)
        break
      }
      print out
    }
  ' | awk '
    {
      line = $0
      while (match(line, /\\?(Make)?CDossier[A-Za-z]+/)) {
        name = substr(line, RSTART, RLENGTH)
        sub(/^\\/, "", name)
        print name
        line = substr(line, RSTART + RLENGTH)
      }
    }
  ' | sort -u
}

# check_coverage <backlog> <defined> <tested> -- the two name lists are
# newline-separated strings. Prints one line per finding and returns 1 if
# there are any.
check_coverage() {
  local bl="$1" defined="$2" tested="$3" line name reason frozen listed=0 bad=0
  local nl='
' declared="
"
  frozen="$(sed -n 's/^# FROZEN AT \([0-9][0-9]*\) entries.*/\1/p' "$bl" | head -n 1)"
  if [ -z "$frozen" ]; then
    printf '  %-30s %s\n' "$(basename "$bl")" "NO FROZEN SIZE: it must carry a '# FROZEN AT <n> entries' line"
    return 1
  fi
  while IFS= read -r line; do
    case "$line" in ''|'#'*) continue ;; esac
    listed=$((listed + 1))
    name="${line%%[[:space:]]*}"
    reason="${line#"$name"}"
    reason="${reason#"${reason%%[![:space:]]*}"}"
    declared="$declared$name$nl"
    if [ -z "$reason" ]; then
      printf '  %-30s %-26s %s\n' "$(basename "$bl")" "NO REASON" "$name"; bad=1
    fi
    case "$nl$defined$nl" in
      *"$nl$name$nl"*) ;;
      *) printf '  %-30s %-26s %s\n' "$(basename "$bl")" "STALE ENTRY" "$name"; bad=1; continue ;;
    esac
    case "$nl$tested$nl" in
      *"$nl$name$nl"*) printf '  %-30s %-26s %s\n' "$(basename "$bl")" "COVERED, DROP THE ENTRY" "$name"; bad=1 ;;
    esac
  done < "$bl"
  if [ "$listed" -gt "$frozen" ]; then
    printf '  %-30s %-26s %s\n' "$(basename "$bl")" "OVER THE FROZEN SIZE" "$listed entries, frozen at $frozen"; bad=1
  fi
  for name in $defined; do
    case "$nl$tested$nl" in *"$nl$name$nl"*) continue ;; esac
    case "$declared" in *"$nl$name$nl"*) continue ;; esac
    printf '  %-30s %-26s %s\n' "\\$name" "UNTESTED NAME" "no tests/regression/*.lvt names it outside a comment"; bad=1
  done
  return "$bad"
}

cd "$root" || exit 1

# The Work's .sty and .cls files, from the manifest; run-manual-names.sh's
# work_files parse.
work=()
for f in $(awk '
    /^The Work$/            { inwork = 1; next }
    /^Distributed with the/ { inwork = 0 }
    /^Not distributed$/     { inwork = 0 }
    inwork && $1 ~ /\.(sty|cls)$/ { print $1 }
  ' manifest.txt); do
  [ -f "$f" ] && work+=("$f")
done

# The regression tests, and the support files they \input.
tests=()
for f in $(git ls-files -- 'tests/regression/*.lvt'); do
  tests+=("$f")
done
for inc in $(git ls-files -- 'tests/regression/support/'); do
  if [ "${#tests[@]}" -gt 0 ] && \
     grep -qF -- "\\input{$(basename "$inc")}" "${tests[@]}"; then
    tests+=("$inc")
  fi
done

defined="$(public_names "${work[@]}")"
tested="$(public_names "${tests[@]}")"

if [ "${1:-}" = "--list" ]; then
  nl='
'
  for name in $defined; do
    case "$nl$tested$nl" in
      *"$nl$name$nl"*) printf '%s\ttested\n' "$name" ;;
      *) printf '%s\tbacklog\n' "$name" ;;
    esac
  done
  exit 0
fi

echo "== ASSERTION: every public name appears in a regression test =="
if [ -z "$defined" ] || [ "${#tests[@]}" -eq 0 ]; then
  echo "  FAIL: found ${#work[@]} Work files and ${#tests[@]} tests, and no name or no test,"
  echo "  so nothing was checked."
  fail=1
elif out="$(check_coverage "$backlog" "$defined" "$tested")"; then
  total="$(text_count_lines "$defined" CDossier)" || total="?"
  remaining="$(grep -cvE '^(#|$)' "$backlog")"
  echo "  $total public names in ${#work[@]} Work files, ${#tests[@]} test files: $((total - remaining)) tested, $remaining on the backlog"
  echo "  (--list prints them)"
  if [ "$remaining" -eq 0 ]; then
    echo "  the backlog is empty: delete $(basename "$backlog") and the backlog branch here (#694)"
  fi
else
  printf '%s\n' "$out"
  echo
  echo "  Assert each untested name in a tests/regression/*.lvt. A backlog entry"
  echo "  only ever leaves: see $(basename "$backlog") and docs/TESTING.md,"
  echo "  \"Name-coverage lint\"."
  fail=1
fi

echo
echo "== CONTROLS =="
fx="$here/fixtures"
fx_defined="$(public_names "$fx/namefixture-work.sty")"
fx_partial="$(public_names "$fx/namefixture-partial.lvt")"
fx_full="$(public_names "$fx/namefixture-partial.lvt" "$fx/namefixture-full.lvt")"
control() { # <label> <expect: OK|verdict> <backlog> <tested>
  local label="$1" expect="$2" bl="$3" got
  got="$(check_coverage "$bl" "$fx_defined" "$4")"
  if { [ "$expect" = OK ] && [ -z "$got" ]; } || \
     { [ "$expect" != OK ] && grep -qF -- "$expect" <<< "$got"; }; then
    printf '  %-28s %s as intended\n' "$label" "$expect"
  else
    printf '  %-28s FAILED: expected %s, got:\n' "$label" "$expect"
    printf '%s\n' "${got:-    (nothing)}" | sed 's/^/    /'
    fail=1
  fi
}
if [ "$(text_count_lines "$fx_defined" CDossier)" != 2 ]; then
  echo "  namefixture-work.sty should define two public names; got: $fx_defined"
  fail=1
fi
control "all tested, no backlog"     OK                        "$fx/namebacklog-empty.txt"    "$fx_full"
control "untested, undeclared"       "UNTESTED NAME"           "$fx/namebacklog-empty.txt"    "$fx_partial"
control "untested, declared"         OK                        "$fx/namebacklog-ok.txt"       "$fx_partial"
control "declared, now tested"       "COVERED, DROP THE ENTRY" "$fx/namebacklog-ok.txt"       "$fx_full"
control "entry with no reason"       "NO REASON"               "$fx/namebacklog-noreason.txt" "$fx_partial"
control "entry for no name"          "STALE ENTRY"             "$fx/namebacklog-stale.txt"    "$fx_partial"
control "entries over frozen"        "OVER THE FROZEN SIZE"    "$fx/namebacklog-over.txt"     "$fx_partial"

echo
if [ "$fail" -eq 0 ]; then
  echo "NAME COVERAGE LINT PASSED"
else
  echo "NAME COVERAGE LINT FAILED"
fi
exit "$fail"
