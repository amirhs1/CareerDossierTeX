#!/usr/bin/env bash
# run-smoke-verdicts.sh — issue #695: a smoke entry whose verdict the runner
# cannot read fails the suite and names the entry.
#
# `smoke_case' in tests/smoke/run.sh has a branch per verdict, `pass', `fail',
# and `fail-once'. Before #695 it had no branch for anything else, so an entry
# such as `foo Pass', or `foo pass needle' written in the space-separated form
# the runner's header once documented, matched nothing and counted as passed.
#
# This plants such entries in a scratch copy of the runner and runs each one
# alone. Each must make the runner exit nonzero, print UNKNOWN VERDICT, and
# quote the planted entry. A copy of the real runner, not a reimplementation,
# so the claim is about the parser `make smoke' uses. Property test: the
# expected outcome is the documented one, and no reference output exists.
#
# The verdict is checked before the fixture file and before any compile, so
# this needs no TeX and no fixture: on a runner without the check, the planted
# entry reports MISSING fixture instead, which names neither the verdict nor the
# entry, and this fails.
#
# Requirements: bash and awk. Run from anywhere.
set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../.." && pwd)"
runner="$root/tests/smoke/run.sh"

scratch="$root/build/lint/smoke-verdicts"
rm -rf "$scratch"
mkdir -p "$scratch/tests/smoke" "$scratch/tests/lib" || exit 2
cp "$root/tests/lib/text.sh" "$scratch/tests/lib/" || exit 2

fail=0
arms=0

# One planted entry per arm. Each basename is selected alone by its own filter,
# so the runner's verdict line is about that entry and nothing else.
while IFS= read -r planted; do
  [ -n "$planted" ] || continue
  arms=$(( arms + 1 ))
  base="${planted%% *}"
  # Insert the entry as the first element of `cases'; refuse a runner that has
  # no such array, rather than testing a copy that plants nothing.
  if ! awk -v entry="$planted" '
         { print }
         /^cases=[(]$/ && !done { printf "  \"%s\"\n", entry; done = 1 }
         END { if (!done) exit 1 }
       ' "$runner" > "$scratch/tests/smoke/run.sh"; then
    echo "  CANNOT PLANT: no 'cases=(' line in $runner"
    fail=1
    continue
  fi
  chmod +x "$scratch/tests/smoke/run.sh"
  output="$("$scratch/tests/smoke/run.sh" "$base" 2>&1)"
  rc=$?
  problems=""
  [ "$rc" -ne 0 ] || problems="$problems exit-0"
  case "$output" in *"UNKNOWN VERDICT"*) ;; *) problems="$problems no-UNKNOWN-VERDICT" ;; esac
  case "$output" in *"\"$planted\""*) ;; *) problems="$problems entry-not-named" ;; esac
  if [ -z "$problems" ]; then
    echo "  rejected by name (exit $rc): \"$planted\""
  else
    echo "  NOT REJECTED: \"$planted\" (exit $rc;$problems)"
    printf '%s\n' "$output" | sed 's/^/    | /'
    fail=1
  fi
done <<'EOF'
verdictcontrol-capital Pass
verdictcontrol-spaced pass needle
verdictcontrol-unknown fail-twice|needle
verdictcontrol-bare
EOF

if [ "$arms" -eq 0 ]; then
  echo "NO ARM RAN: the control checked nothing."
  fail=1
fi

echo
[ "$fail" -eq 0 ] && echo "SMOKE VERDICT CONTROL PASSED ($arms entries rejected)" \
                  || echo "SMOKE VERDICT CONTROL FAILED"
exit "$fail"
