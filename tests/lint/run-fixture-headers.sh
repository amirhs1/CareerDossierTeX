#!/usr/bin/env bash
# run-fixture-headers.sh — every fixture's first line names the file (#534)
#
# `docs/TESTING.md' says each file under tests/ opens with a header comment
# stating what it asserts and why, at the code that does it, and defers each
# suite's description to its files on the strength of that. The deferral only
# works if the headers are there. This lint makes the first half checkable.
#
# WHAT IT ASSERTS
#
# Every fixture's first line contains the fixture's own file name. A fixture is
# a tracked `.tex', `.inc', or `.lvt' file under tests/, except tests/lib/ and
# tests/lint/fixtures/, whose shared helpers and lint inputs have conventions
# of their own. One rule for all three extensions: #534's probe put the name on
# line 1 of a regression include and a smoke include, and the `.tlg' baseline
# and the smoke fixtures that read them passed unchanged, because a comment
# writes nothing to the log.
#
# It does not judge what the header says beyond naming the file. A lint can
# see that a header exists; it cannot see whether its reason is any good, and
# does not pretend to.
#
# THE BACKLOG
#
# tests/lint/fixture-headers-backlog.txt declares the fixtures that did not
# name themselves when this lint landed. It may only shrink, and this lint
# makes that true rather than asking for it:
#
#   - a fixture that does not name itself and is not declared fails
#     (UNNAMED FIXTURE);
#   - an entry with no reason fails (NO REASON);
#   - an entry naming a file that is no longer a fixture fails (STALE ENTRY);
#   - an entry whose fixture now names itself fails (FIXED, DROP THE ENTRY),
#     so a fixed header shrinks the list in the same change;
#   - more entries than the `FROZEN AT <n>' line declares fails
#     (OVER THE FROZEN SIZE), so the list cannot grow by adding to it.
#
# THE CONTROLS
#
# Each verdict above runs against tests/lint/fixtures/headerfixture-*.tex and
# a backlog under tests/lint/fixtures/ through the same check_headers function
# the assertion uses, so a lint that stopped detecting anything fails here.
#
# Requirements: bash, awk, git, and grep. Run from anywhere. No TeX.
set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../.." && pwd)"
backlog="$here/fixture-headers-backlog.txt"
fail=0

# names_itself <file> -- 0 when the first line contains the file's basename.
names_itself() {
  local first
  first="$(head -n 1 "$1")"
  case "$first" in
    *"$(basename "$1")"*) return 0 ;;
    *) return 1 ;;
  esac
}

# check_headers <backlog> <file>... -- prints one line per finding and
# returns 1 if there are any. Paths are as given; the backlog names them the
# same way.
check_headers() {
  local bl="$1" f path reason frozen listed bad=0 declared=" "
  shift
  frozen="$(sed -n 's/^# FROZEN AT \([0-9][0-9]*\) entries.*/\1/p' "$bl" | head -n 1)"
  if [ -z "$frozen" ]; then
    printf '  %-30s %s\n' "$(basename "$bl")" "NO FROZEN SIZE: it must carry a '# FROZEN AT <n> entries' line"
    return 1
  fi
  listed=0
  while IFS= read -r line; do
    case "$line" in ''|'#'*) continue ;; esac
    listed=$((listed + 1))
    path="${line%%[[:space:]]*}"
    reason="${line#"$path"}"
    reason="${reason#"${reason%%[![:space:]]*}"}"
    declared="$declared$path "
    if [ -z "$reason" ]; then
      printf '  %-30s %-24s %s\n' "$(basename "$bl")" "NO REASON" "$path"; bad=1
    fi
    case " $* " in
      *" $path "*) ;;
      *) printf '  %-30s %-24s %s\n' "$(basename "$bl")" "STALE ENTRY" "$path"; bad=1; continue ;;
    esac
    if names_itself "$path"; then
      printf '  %-30s %-24s %s\n' "$(basename "$bl")" "FIXED, DROP THE ENTRY" "$path"; bad=1
    fi
  done < "$bl"
  if [ "$listed" -gt "$frozen" ]; then
    printf '  %-30s %-24s %s\n' "$(basename "$bl")" "OVER THE FROZEN SIZE" "$listed entries, frozen at $frozen"; bad=1
  fi
  for f in "$@"; do
    names_itself "$f" && continue
    case "$declared" in
      *" $f "*) ;;
      *) printf '  %-30s %-24s %s\n' "$f" "UNNAMED FIXTURE" "its first line does not name the file"; bad=1 ;;
    esac
  done
  return "$bad"
}

# The fixtures, repository-relative, so the backlog can name them that way.
cd "$root" || exit 1
fixtures=()
for f in $(git ls-files -- 'tests/*.tex' 'tests/*.inc' 'tests/*.lvt' \
             ':!tests/lib/' ':!tests/lint/fixtures/'); do
  fixtures+=("$f")
done

echo "== ASSERTION: every fixture's first line names the file =="
if [ "${#fixtures[@]}" -eq 0 ]; then
  echo "  FAIL: git listed no fixture, so nothing was checked."
  fail=1
elif out="$(check_headers "$backlog" "${fixtures[@]}")"; then
  remaining="$(grep -cvE '^(#|$)' "$backlog")"
  echo "  ${#fixtures[@]} fixtures: $(( ${#fixtures[@]} - remaining )) name themselves, $remaining on the backlog"
  if [ "$remaining" -eq 0 ]; then
    echo "  the backlog is empty: delete $(basename "$backlog") and the backlog branch here (#534)"
  fi
else
  printf '%s\n' "$out"
  echo
  echo "  Name the file on its first line, as \`% <file> — <what it asserts>'."
  echo "  See docs/TESTING.md, \"Fixture-header lint\"."
  fail=1
fi

echo
echo "== CONTROLS =="
fx="tests/lint/fixtures"
control() { # <label> <expect: OK|verdict> <backlog> <file>...
  local label="$1" expect="$2" bl="$3" got
  shift 3
  got="$(check_headers "$bl" "$@")"
  if { [ "$expect" = OK ] && [ -z "$got" ]; } || \
     { [ "$expect" != OK ] && grep -qF -- "$expect" <<< "$got"; }; then
    printf '  %-26s %s as intended\n' "$label" "$expect"
  else
    printf '  %-26s FAILED: expected %s, got:\n' "$label" "$expect"
    printf '%s\n' "${got:-    (nothing)}" | sed 's/^/    /'
    fail=1
  fi
}
control "named, no backlog"   OK                       "$fx/headerbacklog-empty.txt"    "$fx/headerfixture-named.tex"
control "unnamed, undeclared" "UNNAMED FIXTURE"        "$fx/headerbacklog-empty.txt"    "$fx/headerfixture-unnamed.tex"
control "unnamed, declared"   OK                       "$fx/headerbacklog-ok.txt"       "$fx/headerfixture-unnamed.tex"
control "entry with no reason" "NO REASON"             "$fx/headerbacklog-noreason.txt" "$fx/headerfixture-unnamed.tex"
control "entry for no fixture" "STALE ENTRY"           "$fx/headerbacklog-stale.txt"    "$fx/headerfixture-unnamed.tex"
control "entry already fixed" "FIXED, DROP THE ENTRY"  "$fx/headerbacklog-fixed.txt"    "$fx/headerfixture-named.tex"
control "entries over frozen" "OVER THE FROZEN SIZE"   "$fx/headerbacklog-over.txt"     "$fx/headerfixture-unnamed.tex" "$fx/headerfixture-unnamed-2.tex"

echo
if [ "$fail" -eq 0 ]; then
  echo "FIXTURE HEADER LINT PASSED"
else
  echo "FIXTURE HEADER LINT FAILED"
fi
exit "$fail"
