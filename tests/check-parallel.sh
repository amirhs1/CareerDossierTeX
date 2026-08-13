#!/usr/bin/env bash
# check-parallel.sh — run `make check`'s independent targets concurrently.
#
# WHAT THIS IS
#
# A driver, not a twelfth suite. It asks the Makefile which targets `check`
# runs, dispatches each one as its own `make <target>`, and replays their
# captured output in the Makefile's own order. Every assertion is made by the
# suite that already made it serially; nothing here changes how a suite decides,
# only how many of them are in flight at once.
#
# `make check` itself is untouched and stays serial: it is the pre-push gate and
# the CI-aligned entry point, and a gate whose result depends on scheduling is
# not a gate. This is the opt-in fast path for the one full run before a push.
#
# WHY NOT `make -j`
#
# Three reasons, in order of how hard they are to work around:
#
#   1. macOS ships GNU make 3.81, which has no `--output-sync`. Under `-j` the
#      eleven suites interleave their output line by line and "which suite
#      failed" stops being answerable from the transcript.
#   2. `make -j check` would also fan out *inside* `examples`, whose six
#      sub-targets all latexmk into $(EXAMPLES_BUILD_DIR). That is a collision
#      this script does not have, because it dispatches `examples` whole.
#   3. There is nowhere in a makefile to put the accounting assertion below.
#
# WHAT IT ASSERTS BEYOND THE SUITES
#
# This repository's characteristic failure is a check that reports green
# without doing the work: a sandboxed TeX run typesets nothing and passes, a
# stale artifact reads as evidence, `grep -q` loses a race to SIGPIPE. Running
# eleven suites concurrently adds a fresh instance of that class — a worker that
# dies before its suite ever ran leaves no failure behind, only an absence — so
# two checks here are the substance rather than paperwork:
#
#   - ACCOUNTING. Every dispatched target must leave a result file. The run
#     fails loudly when the number of results is not the number dispatched, and
#     names the targets that produced none. A worker killed by the OOM killer,
#     by a `cd` that failed, or by anything else that stops it before it can
#     record an exit code is caught here and nowhere else.
#   - FONT CACHE. LuaLaTeX needs to write luaotfload's font cache. Where it
#     cannot, fontspec falls back to nullfont, every document typesets empty,
#     and every suite passes having measured nothing. Serially the first suite
#     pays the cache-warming cost once; under fan-out eleven processes race to
#     build it at once, which is exactly when it goes wrong. So the cache is
#     warmed by one small build before any worker starts, and that build is
#     required to prove it typeset real glyphs.
#
# `--self-test` exercises both the accounting assertion and the failure path
# against synthetic workers, compiles nothing, and needs no TeX. `make lint`
# runs it, which is how the negative control stays committed rather than
# performed once by hand.
#
# WHERE IT RUNS
#
# Written for macOS /bin/bash 3.2 as well as modern bash. No `wait -n` (bash
# >= 4.3), no associative arrays, and no process substitution — intermediates go
# to the scratch directory, because some sandboxed environments deny /dev/fd.
# The worker throttle polls `jobs -rp` for the same reason the linebreak sweep
# does; see tests/layout/sweep-linebreak-parallel.sh, which is the precedent
# this file copies.
#
# It needs whatever `make check` needs. Run it from an ordinary interactive
# shell: under a restricted sandbox the font-cache proof below is what fails,
# and it fails before any suite has had the chance to report a hollow pass.
#
# USAGE
#
#   tests/check-parallel.sh [--jobs N] [--list] [--self-test]
#
#   --jobs       concurrent targets; default 4. Capped at the number of targets.
#   --list       print the target list the run would dispatch, and exit.
#   --self-test  run the accounting and failure-path controls; compile nothing.
#
# Output lands in build/check-parallel/, which is gitignored and removed by
# `make clean`. Each target's full stdout and stderr is kept there as
# NN-<target>.log whether it passed or failed.

set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/.." && pwd)"

jobs=4
mode=run

die() {
  printf 'check-parallel: %s\n' "$*" >&2
  exit 1
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --jobs)
      [ "$#" -ge 2 ] || die "--jobs needs a value"
      jobs="$2"
      shift 2
      ;;
    --jobs=*)
      jobs="${1#--jobs=}"
      shift
      ;;
    --list)
      mode=list
      shift
      ;;
    --self-test)
      mode=self-test
      shift
      ;;
    -h|--help)
      # The header, to wherever it ends — a fixed line range would print the
      # first line of code the next time the header grows or shrinks.
      awk 'NR == 1 { next }
           /^#/    { sub(/^# ?/, ""); print; next }
                   { exit }' "$0"
      exit 0
      ;;
    *)
      # An unrecognised option is rejected rather than ignored: a typo that
      # silently became "run with the defaults" would report a clean run of
      # something other than what was asked for.
      die "unrecognised option: $1"
      ;;
  esac
done

case "$jobs" in
  ''|*[!0-9]*) die "--jobs takes a positive integer, got: $jobs" ;;
esac
[ "$jobs" -ge 1 ] || die "--jobs takes a positive integer, got: $jobs"

# --------------------------------------------------------------------------
# The target list.
#
# It is read from the Makefile rather than written here. `check` and this
# script therefore cannot dispatch different sets: both expand the one
# CHECK_TARGETS variable, and `--self-test` asserts that `check`'s prerequisite
# list is still literally that variable. A hand-maintained second copy is how
# the annotations suite once dropped out of a run that was then reported clean.

scratch="$root/build/check-parallel"
[ "$mode" = "self-test" ] && scratch="$root/build/check-parallel-selftest"

targets=()

read_targets() {
  if ! (cd "$root" && make --no-print-directory check-targets) \
       > "$scratch/targets.txt" 2> "$scratch/targets.err"; then
    printf 'check-parallel: `make check-targets` failed:\n' >&2
    sed 's/^/  /' "$scratch/targets.err" >&2
    return 1
  fi
  local line
  while IFS= read -r line; do
    # Guard against a target name with whitespace in it, which would make the
    # dispatch loop below silently run something other than one target.
    case "$line" in
      '') continue ;;
      *[[:space:]]*)
        printf 'check-parallel: target name contains whitespace: %s\n' "$line" >&2
        return 1
        ;;
    esac
    targets+=("$line")
  done < "$scratch/targets.txt"
  if [ "${#targets[@]}" -eq 0 ]; then
    printf 'check-parallel: `make check-targets` named no targets\n' >&2
    return 1
  fi
  return 0
}

# --------------------------------------------------------------------------
# Dispatch and collect.
#
# Split in two so that --self-test can drive the collector over a batch whose
# outcomes it chose. batch_names/batch_cmds are the input; the collector reads
# only the result files on disk, which is what makes "a worker left no result"
# a state it can actually observe.

batch_names=()
batch_cmds=()

slot_for() { printf '%02d-%s' "$1" "$2"; }

run_batch() {
  local n i name cmd slot
  n="${#batch_names[@]}"
  for (( i = 0; i < n; i++ )); do
    name="${batch_names[$i]}"
    cmd="${batch_cmds[$i]}"
    slot="$(slot_for "$i" "$name")"
    printf '  dispatch [%d/%d] %s\n' "$((i + 1))" "$n" "$name"
    (
      cd "$root" || exit 127
      start="$SECONDS"
      # The nested subshell is load-bearing: a command that calls `exit` would
      # otherwise take the worker with it and skip the result write below,
      # turning an ordinary failure into a vanished worker. Dispatched targets
      # are external `make` processes and cannot do that, but --self-test's
      # controls can, and a machine that behaves differently under test than in
      # use is not evidence about the machine in use.
      ( eval "$cmd" ) > "$scratch/$slot.log" 2>&1
      code="$?"
      # Written last and in one line, so a half-written result is not a
      # plausible reading of a missing one.
      printf '%s %s\n' "$code" "$((SECONDS - start))" > "$scratch/$slot.status"
    ) &
    # Throttle without `wait -n` (bash >= 4.3 only; macOS /bin/bash is 3.2).
    while [ "$(jobs -rp | wc -l | tr -d ' ')" -ge "$jobs" ]; do
      sleep 1
    done
  done
  wait
}

# Replays every target's captured output in the Makefile's order, then the
# summary, then the two verdicts. Returns 0 only when every dispatched target
# left a result and every result is 0.
collect_batch() {
  local n i name slot code elapsed completed=0 failed=0 missing=0
  local -a states times
  n="${#batch_names[@]}"
  states=()
  times=()

  for (( i = 0; i < n; i++ )); do
    name="${batch_names[$i]}"
    slot="$(slot_for "$i" "$name")"
    if [ ! -f "$scratch/$slot.status" ]; then
      states+=("NO-RESULT")
      times+=("-")
      missing=$((missing + 1))
      continue
    fi
    completed=$((completed + 1))
    code=""
    elapsed=""
    read -r code elapsed < "$scratch/$slot.status"
    case "$code" in
      ''|*[!0-9]*)
        states+=("NO-RESULT")
        times+=("-")
        # A result file that exists but does not parse is an absent result, not
        # a pass. Counted as missing so the accounting assertion sees it.
        completed=$((completed - 1))
        missing=$((missing + 1))
        continue
        ;;
    esac
    times+=("${elapsed:-?}")
    if [ "$code" -eq 0 ]; then
      states+=("ok")
    else
      states+=("FAILED($code)")
      failed=$((failed + 1))
    fi
  done

  printf '\n'
  for (( i = 0; i < n; i++ )); do
    name="${batch_names[$i]}"
    slot="$(slot_for "$i" "$name")"
    printf -- '----- %s (%s) -----\n' "$name" "${states[$i]}"
    if [ -f "$scratch/$slot.log" ]; then
      cat "$scratch/$slot.log"
    else
      printf '  (no output captured; the worker left no log)\n'
    fi
    printf '\n'
  done

  printf '===== summary =====\n'
  for (( i = 0; i < n; i++ )); do
    printf '  %-22s %-12s %ss\n' "${batch_names[$i]}" "${states[$i]}" "${times[$i]}"
  done
  printf '  logs: %s/NN-<target>.log\n' "$scratch"

  # The accounting assertion. Stated as its own verdict rather than folded into
  # the pass/fail line, because "nothing failed" and "everything ran" are
  # different claims and only the second one is at risk here.
  printf '\n  dispatched %d, completed %d\n' "$n" "$completed"
  if [ "$missing" -ne 0 ]; then
    printf '\nACCOUNTING FAILURE: %d of %d targets left no usable result.\n' \
      "$missing" "$n"
    printf 'A worker died before it could record an outcome. These targets did\n'
    printf 'NOT pass; they did not report:\n'
    for (( i = 0; i < n; i++ )); do
      [ "${states[$i]}" = "NO-RESULT" ] && printf '  - %s\n' "${batch_names[$i]}"
    done
    return 1
  fi

  if [ "$failed" -ne 0 ]; then
    printf '\nFAILED: %d of %d targets failed:\n' "$failed" "$n"
    for (( i = 0; i < n; i++ )); do
      case "${states[$i]}" in
        FAILED*) printf '  - %s (%s)\n' "${batch_names[$i]}" "${states[$i]}" ;;
      esac
    done
    return 1
  fi

  return 0
}

# --------------------------------------------------------------------------
# Font-cache warming.
#
# One small build, before any worker starts, that is required to prove it
# typeset real glyphs. Exit status alone does not prove it: an unwritable
# luaotfload cache leaves fontspec on nullfont, and a nullfont document
# compiles cleanly and is empty. So the log is checked for the two signatures
# of that state as well. `grep pattern file` rather than `... | grep -q`: the
# pipe form exits at its first match, hands the producer a SIGPIPE, and under
# `pipefail` reports "not found" for something that is there.

warm_font_cache() {
  local warm="$scratch/warm"
  mkdir -p "$warm" || return 1

  if ! command -v lualatex > /dev/null 2>&1; then
    printf 'check-parallel: lualatex not found; `make check` cannot run here.\n' >&2
    return 1
  fi

  cat > "$warm/warm.tex" <<'WARMTEX'
% Generated by tests/check-parallel.sh. Not a fixture: it asserts nothing about
% the classes. It exists to populate luaotfload's cache for the two families
% careerdossier-typography.sty loads, before eleven suites race to do it at once.
\documentclass{article}
\usepackage{fontspec}
\setmainfont{texgyretermes}
\setsansfont{texgyreheros}
\begin{document}
Warming the font cache. \textsf{Sans as well.}
\end{document}
WARMTEX

  if ! (cd "$warm" && lualatex -halt-on-error -interaction=nonstopmode warm.tex) \
       > "$warm/warm.stdout" 2>&1; then
    printf 'check-parallel: the font-cache warm-up build FAILED.\n' >&2
    printf 'Nothing was dispatched. See %s\n' "$warm/warm.stdout" >&2
    tail -20 "$warm/warm.stdout" 2>/dev/null | sed 's/^/  /' >&2
    return 1
  fi

  if [ ! -f "$warm/warm.log" ]; then
    printf 'check-parallel: the warm-up build wrote no log; refusing to fan out.\n' >&2
    return 1
  fi

  if grep 'metric data not found' "$warm/warm.log" > /dev/null 2>&1 \
     || grep 'nullfont' "$warm/warm.log" > /dev/null 2>&1; then
    printf 'check-parallel: the warm-up build typeset with NO REAL FONT.\n' >&2
    printf 'luaotfload could not use its cache, so every suite would compile\n' >&2
    printf 'empty documents and pass. Nothing was dispatched. Run this from an\n' >&2
    printf 'ordinary interactive shell rather than a restricted sandbox.\n' >&2
    printf 'See %s\n' "$warm/warm.log" >&2
    return 1
  fi

  printf '  font cache warm (one build, real glyphs confirmed)\n'
  return 0
}

# --------------------------------------------------------------------------
# --self-test: the committed negative controls.
#
# Three of them, because each covers a way the machinery above could report a
# clean run without one having happened. None compiles anything, so this runs
# in the sub-second `lint` slot and on the TeX-free CI lint runner.

self_test() {
  local fails=0 rc out

  printf '== static contract: check and check-parallel dispatch one target set ==\n'
  # `check`'s prerequisite list must be the variable, not a copy of it. A copy
  # is the drift this whole arrangement exists to make impossible.
  if grep -E '^check:[[:space:]]+\$\(CHECK_TARGETS\)[[:space:]]' \
       "$root/Makefile" > /dev/null 2>&1; then
    printf '  ok: `check` expands $(CHECK_TARGETS)\n'
  else
    printf '  FAIL: Makefile `check:` no longer reads `$(CHECK_TARGETS)`.\n'
    printf '        The serial and parallel paths can now dispatch different\n'
    printf '        target sets, which no run would report.\n'
    fails=$((fails + 1))
  fi

  if read_targets; then
    printf '  ok: `make check-targets` named %d targets\n' "${#targets[@]}"
  else
    printf '  FAIL: could not read the target list\n'
    fails=$((fails + 1))
  fi

  # Every dispatched name must be .PHONY, or a same-named file in the tree would
  # make `make <target>` a no-op that exits 0 — eleven hollow passes.
  local phony_line phony_names=() name candidate found
  phony_line="$(sed -n 's/^\.PHONY:[[:space:]]*//p' "$root/Makefile" | tr '\n' ' ')"
  for candidate in $phony_line; do phony_names+=("$candidate"); done
  for name in ${targets[@]+"${targets[@]}"}; do
    found=0
    for candidate in ${phony_names[@]+"${phony_names[@]}"}; do
      [ "$candidate" = "$name" ] && found=1 && break
    done
    if [ "$found" -eq 0 ]; then
      printf '  FAIL: dispatched target `%s` is not declared .PHONY\n' "$name"
      fails=$((fails + 1))
    fi
  done
  [ "$fails" -eq 0 ] && printf '  ok: every dispatched target is .PHONY\n'

  printf '\n== control 1: a batch in which everything succeeds must pass ==\n'
  batch_names=(alpha beta gamma)
  batch_cmds=("printf 'alpha ran\\n'" "printf 'beta ran\\n'" "printf 'gamma ran\\n'")
  run_batch > "$scratch/c1.dispatch" 2>&1
  out="$scratch/c1.collect"
  collect_batch > "$out" 2>&1
  rc="$?"
  if [ "$rc" -eq 0 ] && grep 'dispatched 3, completed 3' "$out" > /dev/null 2>&1; then
    printf '  ok: clean batch passes and accounts for all three\n'
  else
    printf '  FAIL: a clean batch did not pass cleanly (rc=%s); see %s\n' "$rc" "$out"
    fails=$((fails + 1))
  fi

  printf '\n== control 2: one failing member must fail the run, by name ==\n'
  rm -f "$scratch"/*.status "$scratch"/*.log
  batch_names=(alpha beta gamma)
  batch_cmds=("printf 'alpha ran\\n'" "printf 'beta broke\\n'; exit 3" "printf 'gamma ran\\n'")
  run_batch > "$scratch/c2.dispatch" 2>&1
  out="$scratch/c2.collect"
  collect_batch > "$out" 2>&1
  rc="$?"
  if [ "$rc" -ne 0 ] \
     && grep 'FAILED: 1 of 3 targets failed' "$out" > /dev/null 2>&1 \
     && grep -- '- beta (FAILED(3))' "$out" > /dev/null 2>&1 \
     && grep 'beta broke' "$out" > /dev/null 2>&1; then
    printf '  ok: the failure is fatal, named, and its output replayed\n'
  else
    printf '  FAIL: a failing member did not fail the run by name (rc=%s); see %s\n' \
      "$rc" "$out"
    fails=$((fails + 1))
  fi

  printf '\n== control 3: a worker that leaves no result must fail the run ==\n'
  # The one failure parallelism adds that no suite can report on its own: the
  # worker never ran the suite, so there is no failure to find — only an
  # absence. Simulated by removing the result the collector would have read,
  # which is precisely the state a killed worker leaves behind.
  rm -f "$scratch"/*.status "$scratch"/*.log
  batch_names=(alpha beta gamma)
  batch_cmds=("printf 'alpha ran\\n'" "printf 'beta ran\\n'" "printf 'gamma ran\\n'")
  run_batch > "$scratch/c3.dispatch" 2>&1
  rm -f "$scratch/$(slot_for 1 beta).status"
  out="$scratch/c3.collect"
  collect_batch > "$out" 2>&1
  rc="$?"
  if [ "$rc" -ne 0 ] \
     && grep 'ACCOUNTING FAILURE: 1 of 3' "$out" > /dev/null 2>&1 \
     && grep 'dispatched 3, completed 2' "$out" > /dev/null 2>&1; then
    printf '  ok: the missing result is caught, counted, and fatal\n'
  else
    printf '  FAIL: a vanished worker was not caught (rc=%s); see %s\n' "$rc" "$out"
    fails=$((fails + 1))
  fi

  printf '\n'
  if [ "$fails" -ne 0 ]; then
    printf 'check-parallel --self-test: %d control(s) FAILED.\n' "$fails"
    return 1
  fi
  printf 'check-parallel --self-test: all controls passed.\n'
  return 0
}

# --------------------------------------------------------------------------
# Entry points.

rm -rf "$scratch"
mkdir -p "$scratch" || die "cannot create $scratch"

case "$mode" in
  self-test)
    self_test
    exit "$?"
    ;;
  list)
    read_targets || exit 1
    printf '%s\n' ${targets[@]+"${targets[@]}"}
    exit 0
    ;;
esac

read_targets || exit 1

if [ "$jobs" -gt "${#targets[@]}" ]; then
  jobs="${#targets[@]}"
fi

printf 'check-parallel: %d targets, %d at a time\n' "${#targets[@]}" "$jobs"
printf '(the gate is the serial `make check`; this is the fast pre-push run)\n\n'

warm_font_cache || exit 1
printf '\n'

started="$SECONDS"

batch_names=(${targets[@]+"${targets[@]}"})
batch_cmds=()
for target in ${targets[@]+"${targets[@]}"}; do
  batch_cmds+=("make $target")
done

run_batch
collect_batch
verdict="$?"

printf '\n  wall clock: %ss\n' "$((SECONDS - started))"

if [ "$verdict" -ne 0 ]; then
  exit 1
fi

printf '\nAll suites passed.\n'
