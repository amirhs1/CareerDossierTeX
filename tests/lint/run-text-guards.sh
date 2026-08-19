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
scratch_dir="$root/build/text-guards-selftest"
rm -rf "$scratch_dir"

# shellcheck source=tests/lib/text.sh
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

printf '\n== control 6: a count answers three states too ==\n'
# The hollow pass arriving as arithmetic. `grep -Fc` over text that was never
# extracted answers 0, and 0 is the *passing* value for every count comparison
# in this harness — `-ne 0` for the page-one label count, `-eq 1` for the
# orphaned bullet. So a count owes the same third state a predicate does, and
# the unavailable case is the one that used to read as a clean page.
c6_fail=0
counted="$(text_count_lines "$present_text" "Cover Letter")"
[ "$?" -eq 0 ] && [ "$counted" = "1" ] || c6_fail=1
counted="$(text_count_lines "$present_text" "Résumé")"
[ "$?" -eq 0 ] && [ "$counted" = "0" ] || c6_fail=1
text_count_lines "$unavailable" "Cover Letter" > /dev/null
[ "$?" -eq 2 ] || c6_fail=1
text_count_lines "$present_text" '' > /dev/null
[ "$?" -eq 2 ] || c6_fail=1

counted="$(text_count_matches "$present_text" '^Page [0-9]+ of [0-9]+$')"
[ "$?" -eq 0 ] && [ "$counted" = "1" ] || c6_fail=1
counted="$(text_count_matches "$present_text" '^nothing$')"
[ "$?" -eq 0 ] && [ "$counted" = "0" ] || c6_fail=1
text_count_matches "$unavailable" '^Page' > /dev/null
[ "$?" -eq 2 ] || c6_fail=1

if [ "$c6_fail" -eq 0 ]; then
  printf '  ok: both counters return a count, a zero, and an unknown apart\n'
else
  printf '  FAIL: a counter conflated "could not count" with a count of zero.\n'
  printf '        Zero is the passing value for every count guard here, so that\n'
  printf '        conflation is a silent pass, not a noisy failure.\n'
  fails=$((fails + 1))
fi

printf '\n== control 7: no runner still asks the two-state question ==\n'
# The ratchet. Everything above is about the predicate being right; this is about
# it being the one the runners use. A single reintroduced `... | grep -q` is one
# more guard that cannot tell a failed check from a verdict, and no run would
# report it — the suite would go on passing, which is how the shape survived
# this long.
#
# Scoped to the runners and the shared libraries, which is every script that
# asserts on captured text. It is deliberately not scoped to a list of known
# sites: a new runner with the old shape is exactly what this must catch.
#
# `-q` and `-c` both, because a count needs this more than a boolean does. A
# guard reading `grep -Fc … || true` over text it never extracted gets 0, and 0
# is the passing value for every such comparison here — the same hollow pass,
# arriving as arithmetic. Two sites shipped that way and are fixed alongside
# this widening.
#
# Some counts are legitimately safe — a count that is only printed, or one
# compared against an independently derived expected value, cannot turn "could
# not check" into a pass. Those say so at the site with a
#
#   # guard-ok: <reason>
#
# marker, rather than in an exemption list here, which would rot apart from the
# code it describes. Two properties make the marker worth trusting: it must
# carry a reason, so exempting a line costs an argument rather than a keyword;
# and it shields only the contiguous run of code lines that follows it, ending
# at the first blank line, so it cannot silently spread down a file.
#
# The scan is awk rather than grep because that "comment block immediately
# above" relationship is not something a line-at-a-time filter can see.
offenders="$(
  cd "$root" && awk '
    FNR == 1 { shield = 0 }
    /^[[:space:]]*#/ {
      if ($0 ~ /guard-ok:[[:space:]]*[A-Za-z]/) shield = 1
      next
    }
    /^[[:space:]]*$/ { shield = 0; next }
    {
      if ($0 ~ /\|[[:space:]]*grep[[:space:]]+-[A-Za-z]*[qc]/ \
          && shield == 0 \
          && $0 !~ /guard-ok:[[:space:]]*[A-Za-z]/)
        printf "%s:%d:%s\n", FILENAME, FNR, $0
    }
  ' tests/*/run.sh tests/*/run-*.sh tests/lib/*.sh tests/check-parallel.sh \
      2>/dev/null \
    | grep -v '^tests/lint/run-text-guards\.sh:'
)"
# This script is the one blanket exemption, and it is not a carve-out for
# convenience: control 1 above must hold the old spelling in order to
# demonstrate that it fails. Nothing else here may.
if [ -z "$offenders" ]; then
  printf '  ok: no unmarked `| grep -q` or `| grep -c` guard remains\n'
else
  printf '  FAIL: the two-state pipeline guard is back:\n'
  printf '%s\n' "$offenders" | sed 's/^/    /'
  printf '        Use text_contains / text_contains_line / text_matches, or\n'
  printf '        text_count_lines / text_count_matches, from tests/lib/text.sh:\n'
  printf '        they answer "could not check" apart from "absent" and apart\n'
  printf '        from a count of zero. If the site is genuinely safe, say why\n'
  printf '        in a `# guard-ok: <reason>` comment above it. See issue #398.\n'
  fails=$((fails + 1))
fi

printf '\n== control 8: the guard-ok marker must cost an argument ==\n'
# An exemption keyword with no reason is how a ratchet becomes a formality. The
# scanner is re-run over a synthetic file carrying three shapes: a bare marker,
# a marker with a reason, and an offence two blank-separated lines below a
# marker. Only the middle one may be shielded.
marker_probe="$scratch_dir/guard-ok-probe.sh"
mkdir -p "$scratch_dir"
cat > "$marker_probe" <<'PROBE'
# guard-ok:
bare="$(printf '%s\n' "$x" | grep -c .)"
# guard-ok: a stated reason
reasoned="$(printf '%s\n' "$x" | grep -c .)"
# guard-ok: a stated reason

far="$(printf '%s\n' "$x" | grep -c .)"
PROBE
probe_out="$(awk '
  FNR == 1 { shield = 0 }
  /^[[:space:]]*#/ {
    if ($0 ~ /guard-ok:[[:space:]]*[A-Za-z]/) shield = 1
    next
  }
  /^[[:space:]]*$/ { shield = 0; next }
  {
    if ($0 ~ /\|[[:space:]]*grep[[:space:]]+-[A-Za-z]*[qc]/ \
        && shield == 0 \
        && $0 !~ /guard-ok:[[:space:]]*[A-Za-z]/)
      printf "%d\n", FNR
  }
' "$marker_probe" | tr '\n' ' ')"
if [ "$probe_out" = "2 7 " ]; then
  printf '  ok: a bare marker shields nothing, and a reason shields one block\n'
else
  printf '  FAIL: the marker rule flagged lines [%s], expected [2 7 ].\n' "$probe_out"
  printf '        Line 2 is a marker with no reason and line 7 is past a blank\n'
  printf '        line; both must still be caught, or `# guard-ok:` becomes a\n'
  printf '        keyword that silences the ratchet for free.\n'
  fails=$((fails + 1))
fi

printf '\n'
if [ "$fails" -ne 0 ]; then
  printf 'text guards: %d control(s) FAILED.\n' "$fails"
  exit 1
fi
printf 'text guards: all controls passed.\n'
exit 0
