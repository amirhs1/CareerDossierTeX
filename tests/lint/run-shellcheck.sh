#!/usr/bin/env bash
# run-shellcheck.sh — static analysis of the shell harness (#469)
#
# WHAT THIS IS
#
# `tests/` is around 10,900 lines of shell, and every verification claim this
# project makes is a claim about what those scripts did. Nothing checked them
# statically until this runner. It compiles nothing and needs no TeX, so it runs
# in the `lint` slot alongside the other source-level invariants.
#
# THE THRESHOLD, AND WHY IT IS NOT `-S error`
#
# `-S warning`. The threshold is not cosmetic: the first defect this runner
# found -- a `local` whose later assignments dereference the variable being
# declared, tests/tagging/run.sh -- is reported as SC2318, which is
# *warning*-severity. `-S error` would have run clean over it and reported a
# healthy harness. A gate that cannot see the bug it was built for is worse than
# no gate, because it also carries the authority of a passing check.
#
# WHY SILENCE HAS TO MEAN CLEAN
#
# A gate is only useful if a clean run prints nothing. A runner that reports the
# same eighteen known-good lines on every invocation teaches everyone to scroll
# past its output, and the nineteenth line -- the real one -- scrolls past with
# them. So every finding here is either fixed or suppressed *at its site*, with
# a reason, and this runner's own output is empty when the harness is clean.
#
# WHY THE SUPPRESSIONS ARE PER-SITE
#
# A file-level `disable=SC2034` would switch that check off for a whole file
# permanently, including code not yet written. SC2034 is exactly what catches a
# typo'd counter -- `fanout_faild=0` for `fanout_failed=0` -- a variable set and
# never read, which would leave the accounting counter untouched and the run
# reporting a clean suite. That is this repository's characteristic failure, and
# tests/lib/fanout.sh exists to remove it. Per-site directives keep every rule
# live everywhere except the handful of lines a human vouched for.
#
# `-x` AND THE `source=` DIRECTIVES
#
# `-x` alone buys nothing here: the harness sources its libraries through
# variables (`. "$root/tests/lib/text.sh"`), and shellcheck cannot resolve a
# path it would have to execute the script to know. Each such line therefore
# carries a `# shellcheck source=` directive naming the file literally. That is
# a better answer than suppression -- it removed five findings from
# tests/check-parallel.sh by *teaching* shellcheck where the definitions are,
# leaving SC2034 and SC2154 fully active in that file rather than silenced.
#
# Directives resolve relative to the repository root, so this runner works from
# there.
#
# Run from anywhere.
set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../.." && pwd)"

echo "== shellcheck (the shell harness under tests/) =="

# A check that could not be performed is not a check that passed -- the #398
# rule this repository applies everywhere else, and the shape
# tests/lint/run-ctan-config.sh already uses for a missing interpreter.
if ! command -v shellcheck > /dev/null 2>&1; then
  echo "  shellcheck NOT FOUND"
  echo "    -> this lint is the only static check over ~10,900 lines of shell,"
  echo "       and skipping it would report a clean harness having read none"
  echo "       of it. Install it (macOS: brew install shellcheck; Debian and"
  echo "       Ubuntu: apt-get install shellcheck) or run this where it exists."
  echo
  echo "SHELLCHECK LINT FAILED"
  exit 1
fi

# Recorded for the same reason the CI `lint` job records bash, grep, and awk:
# The tool adds checks between releases, so the version is part of what a
# result means.
echo "  $(shellcheck --version | awk '/^version:/ { print "shellcheck " $2 }')"

cd "$root" || exit 1

fail=0
if find tests -name '*.sh' -print0 | xargs -0 shellcheck -x -S warning; then
  echo "  no findings"
else
  fail=1
fi

echo
if [ "$fail" -eq 0 ]; then
  echo "SHELLCHECK LINT PASSED"
else
  echo "SHELLCHECK LINT FAILED"
fi
exit "$fail"
