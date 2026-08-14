#!/usr/bin/env bash
# run-text-guards.sh — the committed negative controls for tests/lib/text.sh.
#
# Issue #398. The runners assert on extracted text through a predicate that must
# answer three things apart: present, absent, and *could not be checked*. The
# defect was a predicate that answered two, so a check that could not run was
# reported as a verdict — as "text missing" in the plain branches, and, in the
# inverted `medium=screen` branches, as a pass.
#
# Every control below drives tests/lib/text.sh over synthetic text. Nothing is
# compiled, so this runs in the sub-second `lint` slot and on the TeX-free CI
# lint runner, next to `tests/check-parallel.sh --self-test`.
#
# Control 1 is the load-bearing one and deserves its reasoning up front. #398
# could not reproduce the failure in isolation: three candidate mechanisms were
# tested over 2000, 640, and 7200 trials and none fired. What *was* established
# is narrower and is what control 1 pins — the check could not run, and the
# guard produced a verdict anyway. Emptying PATH puts a guard into exactly that
# state deterministically, in the one way that needs no load at all: with no
# external command reachable, the old `printf | grep -Fq` form cannot perform
# its check, and reports the text it was handed as missing. So the control does
# not simulate a presumed cause. It reproduces the established symptom, and it
# fails against the old spelling and passes against the new one.

set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../.." && pwd)"
fails=0

. "$root/tests/lib/text.sh"

# The text every control below asks about: the real page-two capture from the
# fixture #398 reported, trimmed to the lines that matter.
present_text="Ada Lovelace – Cover Letter
Page 2 of 2
…continued from the previous page."

label="Cover Letter"

# The two runner-shaped wrappers, in the two polarities every runner uses. They
# are defined here rather than imported because each runner spells its own
# failure sink differently; what is shared, and what is under test, is that both
# polarities treat 2 as a failure of their own rather than as a verdict.
probe_require() { # <text> <needle> <message>
  text_contains "$1" "$2"
  case "$?" in
    0) return 0 ;;
    1) printf '  MISSING: %s\n' "$3"; return 1 ;;
    *) printf '  UNCHECKABLE: %s\n' "$3"; return 1 ;;
  esac
}

probe_forbid() { # <text> <needle> <message>
  text_contains "$1" "$2"
  case "$?" in
    1) return 0 ;;
    0) printf '  UNEXPECTED: %s\n' "$3"; return 1 ;;
    *) printf '  UNCHECKABLE: %s\n' "$3"; return 1 ;;
  esac
}

printf '== control 1: a check that cannot run must not produce a verdict ==\n'
# The old spelling and the new one, over the same present text, in a shell where
# no external program can be reached. `printf` is a bash builtin and still runs;
# `grep` is not and cannot. That is a check that could not be performed.

# Resolved before PATH is emptied, since the assignment below also governs the
# lookup of the command it prefixes.
bash_path="${BASH:-$(command -v bash)}"

old_verdict="$(
  PATH='' "$bash_path" -c '
    set -uo pipefail
    text="$1"; needle="$2"
    if ! printf "%s\n" "$text" | grep -Fq "$needle"; then
      printf "MISSING\n"
    else
      printf "present\n"
    fi
  ' _ "$present_text" "$label" 2>/dev/null
)"
new_verdict="$(
  PATH='' "$bash_path" -c '
    set -uo pipefail
    . "$0"
    text="$1"; needle="$2"
    text_contains "$text" "$needle"
    case "$?" in
      0) printf "present\n" ;;
      1) printf "MISSING\n" ;;
      *) printf "UNCHECKABLE\n" ;;
    esac
  ' "$root/tests/lib/text.sh" "$present_text" "$label" 2>/dev/null
)"

if [ "$old_verdict" != "MISSING" ]; then
  printf '  FAIL: the control did not reproduce the defect it exists to pin.\n'
  printf '        The old `printf | grep -Fq` form answered "%s" with no\n' \
    "$old_verdict"
  printf '        external command reachable, where #398 observed MISSING.\n'
  printf '        Repair this control rather than dropping it: without it\n'
  printf '        nothing here demonstrates the failure being fixed.\n'
  fails=$((fails + 1))
elif [ "$new_verdict" != "present" ]; then
  printf '  FAIL: text_contains answered "%s" for a label that is on line 1.\n' \
    "$new_verdict"
  printf '        It must not depend on an external command being reachable.\n'
  fails=$((fails + 1))
else
  printf '  ok: the old form reported present text MISSING; text_contains did not\n'
fi

printf '\n== control 2: three states, not two ==\n'
# Each predicate, over each of the three answers it owes. The unavailable case
# is the one the old spelling had no room for.
unavailable="$CDTEXT_UNAVAILABLE"

# <expected> <predicate> <text> <needle>. Each disagreement is named rather
# than tallied anonymously, so a failure says which assertion disagreed and
# what it answered. `expect_misses` is reset by the caller before each group.
expect_misses=0
expect_state() {
  local want="$1" pred="$2" text="$3" needle="$4" got
  "$pred" "$text" "$needle"
  got="$?"
  [ "$got" -eq "$want" ] && return 0
  printf '  FAIL: %s answered %s, expected %s\n' "$pred" "$got" "$want"
  expect_misses=$((expect_misses + 1))
  return 1
}

expect_misses=0
expect_state 0 text_contains "$present_text" "$label"
expect_state 1 text_contains "$present_text" "Résumé"
expect_state 2 text_contains "$unavailable" "$label"

expect_state 0 text_contains_line "$present_text" "Page 2 of 2"
expect_state 1 text_contains_line "$present_text" "Page 2"
expect_state 2 text_contains_line "$unavailable" "Page 2 of 2"

expect_state 0 text_matches "$present_text" 'Page [0-9]+ of [0-9]+'
expect_state 1 text_matches "$present_text" '^Résumé$'
expect_state 2 text_matches "$unavailable" 'Page [0-9]+ of [0-9]+'

if [ "$expect_misses" -eq 0 ]; then
  printf '  ok: contains, contains_line, and matches each answer 0, 1, and 2\n'
else
  printf '  FAIL: a predicate did not distinguish present, absent, and unknown\n'
  fails=$((fails + 1))
fi

printf '\n== control 3: an unperformable check fails BOTH polarities ==\n'
# The acceptance criterion #398 states twice. The require half was the observed
# symptom; the forbid half is the one that matters, because there a check that
# could not run used to be indistinguishable from a clean fixture. Both must
# fail, and both must say they could not run rather than name a verdict.
req_out="$(probe_require "$unavailable" "$label" 'running header on page 2')"
req_rc="$?"
fbd_out="$(probe_forbid "$unavailable" "$label" 'screen running header on page 2')"
fbd_rc="$?"

if [ "$req_rc" -eq 0 ] || [ "$fbd_rc" -eq 0 ]; then
  printf '  FAIL: an unperformable check passed (require rc=%s, forbid rc=%s).\n' \
    "$req_rc" "$fbd_rc"
  printf '        The forbid half passing is the hollow pass of #398.\n'
  fails=$((fails + 1))
elif [ "${req_out#*UNCHECKABLE}" = "$req_out" ] \
  || [ "${fbd_out#*UNCHECKABLE}" = "$fbd_out" ]; then
  printf '  FAIL: an unperformable check failed without saying it could not run:\n'
  printf '          require: %s\n' "$req_out"
  printf '          forbid:  %s\n' "$fbd_out"
  printf '        Reported as MISSING or UNEXPECTED, it names a verdict about a\n'
  printf '        document that was never read.\n'
  fails=$((fails + 1))
else
  printf '  ok: both polarities fail, and both name that the check could not run\n'
fi

# And the same two wrappers over real text must still reach their real verdicts,
# or control 3 would pass for a predicate that answered 2 to everything.
c3b_fail=0
probe_require "$present_text" "$label" x > /dev/null || c3b_fail=1
probe_forbid  "$present_text" "Résumé" x > /dev/null || c3b_fail=1
probe_require "$present_text" "Résumé" x > /dev/null && c3b_fail=1
probe_forbid  "$present_text" "$label" x > /dev/null && c3b_fail=1
if [ "$c3b_fail" -eq 0 ]; then
  printf '  ok: over real text both polarities still reach their real verdicts\n'
else
  printf '  FAIL: a wrapper that fails everything would satisfy the control above\n'
  fails=$((fails + 1))
fi

printf '\n== control 4: the needle is matched literally, and is never empty ==\n'
# `case` patterns are globs. The quoting that keeps a needle literal is invisible
# and one edit from being lost, and this repository's needles include
# `ORCID: 0000-0002-1825-0097` and `scholar.google.com/citations?user=...`.
expect_misses=0
expect_state 0 text_contains 'a literal [abc] here' '[abc]'
expect_state 1 text_contains 'a literal b here' '[abc]'
expect_state 0 text_contains 'ORCID: 0000-0002-1825-0097' \
  'ORCID: 0000-0002-1825-0097'
expect_state 1 text_contains 'user=AlexandriaMontgomery' 'user?Alexandria'
expect_state 2 text_contains 'anything at all' ''
expect_state 2 text_contains_line 'anything at all' ''
if [ "$expect_misses" -eq 0 ]; then
  printf '  ok: glob metacharacters are literal; an empty needle is not a pass\n'
else
  printf '  FAIL: a needle was treated as a pattern, or an empty needle passed.\n'
  printf '        `grep -Fq ""` matches everything, which is a guard asserting\n'
  printf '        nothing while reporting a pass.\n'
  fails=$((fails + 1))
fi

printf '\n== control 5: an extraction that could not run marks itself unavailable ==\n'
# The other end of the same contract. A capture writes into an ordinary variable
# through `$(...)`, which discards exit status, so the failure has to survive in
# the value or it does not survive at all.
c5_fail=0
missing_pdf="$(text_extract "$root/tests/lint/no-such-file-anywhere.pdf")"
text_is_unavailable "$missing_pdf" || c5_fail=1
not_a_pdf="$(text_extract "$root/tests/lib/text.sh")"
text_is_unavailable "$not_a_pdf" || c5_fail=1
text_contains "$missing_pdf" "$label"; [ "$?" -eq 2 ] || c5_fail=1
if [ "$c5_fail" -eq 0 ]; then
  printf '  ok: a missing file and an unreadable one both capture as unavailable\n'
else
  printf '  FAIL: a failed extraction captured as ordinary text. Downstream that\n'
  printf '        reads as an empty page, which is a verdict, not an absence.\n'
  fails=$((fails + 1))
fi

printf '\n== control 6: no runner still asks the two-state question ==\n'
# The ratchet. Everything above is about the predicate being right; this is about
# it being the one the runners use. A single reintroduced `... | grep -q` is one
# more guard that cannot tell a failed check from a verdict, and no run would
# report it — the suite would go on passing, which is how the shape survived
# this long.
#
# Scoped to the runners and the shared libraries, which is every script that
# asserts on captured text. It is deliberately not scoped to a list of known
# sites: a new runner with the old shape is exactly what this must catch.
offenders="$(
  cd "$root" \
    && grep -nE '\|[[:space:]]*grep[[:space:]]+-[A-Za-z]*q' \
         tests/*/run.sh tests/*/run-*.sh tests/lib/*.sh tests/check-parallel.sh \
         2>/dev/null \
    | grep -v '^[^:]*:[0-9]*:[[:space:]]*#' \
    | grep -v '^tests/lint/run-text-guards\.sh:'
)"
# This script is the one exemption, and it is not a carve-out for convenience:
# control 1 above must hold the old spelling in order to demonstrate that it
# fails. Nothing else here may.
if [ -z "$offenders" ]; then
  printf '  ok: no `... | grep -q` guard remains in the runners or libraries\n'
else
  printf '  FAIL: the two-state pipeline guard is back:\n'
  printf '%s\n' "$offenders" | sed 's/^/    /'
  printf '        Use text_contains / text_contains_line / text_matches from\n'
  printf '        tests/lib/text.sh, which answer "could not check" apart from\n'
  printf '        "absent". See issue #398.\n'
  fails=$((fails + 1))
fi

printf '\n'
if [ "$fails" -ne 0 ]; then
  printf 'text guards: %d control(s) FAILED.\n' "$fails"
  exit 1
fi
printf 'text guards: all controls passed.\n'
exit 0
