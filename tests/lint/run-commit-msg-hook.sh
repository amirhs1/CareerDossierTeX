#!/usr/bin/env bash
# run-commit-msg-hook.sh — the commit-msg hook's verdicts (#573)
#
# .githooks/commit-msg checks the trailer block of every commit made in a clone
# that ran `git config core.hooksPath .githooks`: one final block, an
# `Assisted-by:` role from the six fixed roles, and no AI `Co-authored-by:`.
# The hook is copied unchanged from the maintainer's shared templates, where
# its full fixture set lives. This runner pins the four verdicts this
# repository relies on, so a hook that stops rejecting is caught here rather
# than discovered in the history.
#
# Each tests/lint/fixtures/commitfixture-*.txt is a commit message:
#
#   commitfixture-accepted.txt     an AI-assisted commit with a fixed role
#   commitfixture-no-trailers.txt  a commit with no trailers at all
#   commitfixture-free-role.txt    an `Assisted-by:` role written as free text
#   commitfixture-ai-coauthor.txt  an AI tool listed as a co-author
#
# The hook exits 0 to accept, 1 to reject, and 2 on a usage error such as a
# missing file. Only 0 and 1 are verdicts: a missing fixture or any other exit
# status is a failure here, never a rejection that happens to match.
#
# It needs only sh and awk, so it runs on the TeX-free CI lint runner.
#
# Run from anywhere.
set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../.." && pwd)"
hook="$root/.githooks/commit-msg"
fixtures="$here/fixtures"
fail=0

echo "== the commit-msg hook's verdicts =="

if [ ! -x "$hook" ]; then
  echo "  FAIL: $hook is missing or not executable"
  echo
  echo "COMMIT-MSG HOOK LINT FAILED"
  exit 1
fi

# expect <fixture> <accept|reject>
expect() {
  local name="$1" want="$2" file="$fixtures/$1" status got
  if [ ! -f "$file" ]; then
    echo "  FAIL: fixture $name is missing"
    fail=1
    return
  fi
  "$hook" "$file" >/dev/null 2>&1
  status=$?
  case "$status" in
    0) got=accept ;;
    1) got=reject ;;
    *)
      echo "  FAIL: $name: the hook exited $status, which is not a verdict"
      fail=1
      return
      ;;
  esac
  if [ "$got" = "$want" ]; then
    echo "  $name ${want}ed as intended"
  else
    echo "  FAIL: $name was ${got}ed; it should be ${want}ed"
    fail=1
  fi
}

expect commitfixture-accepted.txt accept
expect commitfixture-no-trailers.txt accept
expect commitfixture-free-role.txt reject
expect commitfixture-ai-coauthor.txt reject

echo
if [ "$fail" -eq 0 ]; then
  echo "COMMIT-MSG HOOK LINT PASSED"
else
  echo "COMMIT-MSG HOOK LINT FAILED"
fi
exit "$fail"
