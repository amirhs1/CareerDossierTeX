#!/usr/bin/env bash
# run-fixture-filter.sh — CareerDossierTeX suite fixture-selection contract
#
# `make smoke`, `make layout`, and `make extract-test` take an optional
# `FIXTURE=<pattern>` that scopes the run to the fixtures matching it (issue
# #359). That selection is the one part of a test runner whose own failure mode
# is a *pass*: a suite that selects nothing makes none of its assertions and
# reports every one of them clean. This script is what stops that being silent.
#
# For each scopable runner it asserts:
#
#   1. `--list` with no pattern names every *.tex fixture in that directory and
#      nothing else. This is a real check in both directions for the smoke
#      runner, whose fixture universe is a hand-written `cases' array rather
#      than a glob — an entry added without a fixture, or a fixture added
#      without an entry, is caught here rather than at the next full run.
#   2. A pattern that matches selects a proper, non-empty subset, and every name
#      in it really does match the pattern.
#   3. A pattern that matches nothing exits nonzero. Silence here is the whole
#      point of the file.
#   4. An empty pattern selects the full suite, because that is literally what
#      `make smoke` passes when FIXTURE is unset.
#   5. An unrecognised option is rejected rather than taken for a pattern, so a
#      typo cannot quietly become "run one fixture, pass, report a clean suite".
#
# It compiles nothing: every invocation is in `--list` mode, which is why this
# lives with the option lint, runs in the same sub-second `lint` slot, and needs
# no TeX installation on the CI runner that hosts it.
#
# Requirements: bash. Run from anywhere.
set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../.." && pwd)"
fail=0

# suite | a pattern that must match at least one but not all of its fixtures
suites=(
  "smoke|bad-medium"
  "layout|two-page"
  "extraction|statement"
)

for spec in "${suites[@]}"; do
  suite="${spec%%|*}"; pattern="${spec#*|}"
  runner="$root/tests/$suite/run.sh"
  echo "== tests/$suite/run.sh =="

  if [ ! -x "$runner" ]; then
    echo "  MISSING or non-executable runner: $runner"; fail=1; continue
  fi

  # 0. Establish statically that the runner has a `--list' branch, before
  #    invoking it. A runner without one treats `--list' as a fixture pattern,
  #    and every check below would then *compile the whole suite* — turning this
  #    sub-second lint into several minutes of LuaLaTeX on a machine that may
  #    have no TeX at all. Grepping the source first is what keeps a missing
  #    feature a fast, legible failure rather than a hang.
  #    The three runners spell the branch identically on purpose, so one pattern
  #    recognises all of them and a fourth suite joining them has one shape to
  #    copy.
  if ! grep -qE -- '--list\)[[:space:]]*list_only=1' "$runner"; then
    echo "  NO --list BRANCH in $runner. Not invoking it: without that branch"
    echo "    every check below compiles the entire suite instead of listing it."
    fail=1; continue
  fi

  # 1. The unfiltered universe is exactly the fixture files on disk.
  listed="$("$runner" --list)"
  ondisk="$(cd "$root/tests/$suite" && for f in *.tex; do echo "${f%.tex}"; done)"
  listed_sorted="$(printf '%s\n' "$listed" | sort)"
  ondisk_sorted="$(printf '%s\n' "$ondisk" | sort)"
  if [ "$listed_sorted" != "$ondisk_sorted" ]; then
    echo "  UNIVERSE MISMATCH: --list and tests/$suite/*.tex disagree."
    while IFS= read -r name; do
      [ -n "$name" ] || continue
      if ! printf '%s\n' "$ondisk_sorted" | grep -qxF "$name"; then
        echo "      selected but no such fixture file: $name"
      fi
    done <<EOF
$listed_sorted
EOF
    while IFS= read -r name; do
      [ -n "$name" ] || continue
      if ! printf '%s\n' "$listed_sorted" | grep -qxF "$name"; then
        echo "      fixture file never selected: $name"
      fi
    done <<EOF
$ondisk_sorted
EOF
    fail=1
  else
    n_all="$(printf '%s\n' "$listed" | grep -c . || true)"
    echo "  --list names all $n_all fixtures and no others"
  fi

  # 2. A matching pattern selects a proper, non-empty subset, and every selected
  #    name actually contains it. A filter that quietly widened to everything
  #    would still "work" for a developer and would still cost the full suite.
  subset="$("$runner" --list "$pattern")"
  rc=$?
  n_subset="$(printf '%s\n' "$subset" | grep -c . || true)"
  n_all="$(printf '%s\n' "$listed" | grep -c . || true)"
  if [ "$rc" -ne 0 ]; then
    echo "  PATTERN '$pattern' EXITED $rc but matches fixtures"; fail=1
  elif [ "$n_subset" -eq 0 ]; then
    echo "  PATTERN '$pattern' SELECTED NOTHING, expected a subset"; fail=1
  elif [ "$n_subset" -ge "$n_all" ]; then
    echo "  PATTERN '$pattern' SELECTED ALL $n_all fixtures, expected a subset"
    fail=1
  else
    stray=0
    while IFS= read -r name; do
      [ -n "$name" ] || continue
      case "$name" in
        *$pattern*) ;;
        *) echo "  SELECTED '$name' does not match '$pattern'"; stray=1 ;;
      esac
    done <<EOF
$subset
EOF
    if [ "$stray" -eq 0 ]; then
      echo "  '$pattern' selects $n_subset of $n_all, all of them matching"
    else
      fail=1
    fi
  fi

  # 3. A pattern matching nothing must fail the run. This is the assertion the
  #    whole file exists for: the alternative is a green suite that ran nothing.
  nomatch_out="$("$runner" no-such-fixture-anywhere 2>&1)"
  rc=$?
  if [ "$rc" -eq 0 ]; then
    echo "  NON-MATCHING PATTERN EXITED 0. A run that selected no fixture"
    echo "    passes every assertion this suite makes, and reports so."
    fail=1
  elif ! printf '%s\n' "$nomatch_out" | grep -q 'NO FIXTURE MATCHES'; then
    echo "  NON-MATCHING PATTERN failed without saying why:"
    printf '%s\n' "$nomatch_out" | sed 's/^/    /' | head -5
    fail=1
  else
    echo "  a pattern matching nothing exits $rc and says so"
  fi

  # 4. The empty pattern is the full suite. `make smoke` with FIXTURE unset
  #    passes "" as a quoted argument, so this is the default path, not an
  #    edge case.
  empty_listed="$("$runner" --list "")"
  if [ "$(printf '%s\n' "$empty_listed" | sort)" != "$listed_sorted" ]; then
    echo "  EMPTY PATTERN did not select the full suite — this is what"
    echo "    'make $suite' passes when FIXTURE is unset."
    fail=1
  else
    echo "  the empty pattern selects the full suite"
  fi

  # 5. An unknown option must be rejected, not silently taken as a pattern.
  "$runner" --no-such-option > /dev/null 2>&1
  rc=$?
  if [ "$rc" -eq 0 ]; then
    echo "  UNKNOWN OPTION ACCEPTED (exit 0)"; fail=1
  else
    echo "  an unknown option is rejected (exit $rc)"
  fi
done

# The Makefile is the interface the contract above is reached through, so the
# pass-through is asserted too. A recipe that dropped its variable would leave
# every check above passing while `make layout FIXTURE=...` silently ran all 54
# fixtures — slow, not wrong, and therefore easy to never notice.
echo "== Makefile pass-through =="
makefile="$root/Makefile"
# A literal tab, and `grep -F'. A recipe line begins with a tab, and neither
# `\t' in an ERE nor a backslash-heavy escaped pattern survives the two greps
# this suite runs under: local ugrep and GNU grep on the CI runner.
tab="$(printf '\t')"
for suite in smoke layout extraction; do
  # tests/extraction/run.sh is reached through the `extract-test' target.
  if ! grep -qF "${tab}tests/$suite/run.sh \"\$(FIXTURE)\"" "$makefile"; then
    echo "  tests/$suite/run.sh is not invoked with \"\$(FIXTURE)\" in the Makefile"
    fail=1
  else
    echo "  tests/$suite/run.sh receives \"\$(FIXTURE)\""
  fi
done
if ! grep -qF "${tab}l3build check \$(TEST)" "$makefile"; then
  echo "  the regression target does not pass \$(TEST) to l3build check"
  fail=1
else
  echo "  l3build check receives \$(TEST)"
fi

echo
[ "$fail" -eq 0 ] && echo "FIXTURE-SELECTION CONTRACT HELD" \
                  || echo "FIXTURE-SELECTION CONTRACT VIOLATED"
exit "$fail"
