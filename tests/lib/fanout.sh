#!/usr/bin/env bash
# fanout.sh — dispatch a list of units concurrently, collect their verdicts, and
# refuse to summarise until every dispatched unit has left one.
#
# WHAT THIS IS
#
# A library, sourced rather than executed. It holds the four things that are
# genuinely hard about running a suite's own fixtures several at a time, so that
# the three runners which do it — smoke, layout, tagging — share one
# implementation instead of three:
#
#   1. the throttle, without `wait -n` (bash >= 4.3; macOS /bin/bash is 3.2);
#   2. the nested subshell that keeps a unit's `exit` from taking its worker
#      down with it;
#   3. ordered replay, so concurrent output is read in the order the serial
#      runner would have printed it;
#   4. the ACCOUNTING assertion — the substance, and the reason this file is
#      not four lines of `&` and `wait`.
#
# WHY ACCOUNTING IS THE SUBSTANCE
#
# `tests/check-parallel.sh` parallelised *processes that already reported their
# own verdicts*: a dispatched `make layout` either exits 0 or does not, and the
# driver only had to count. Inside a runner there is no such boundary. Each
# fixture's assertions currently write into shell state the loop accumulates —
# counters, `failed` arrays, skip notices — and shell state does not survive a
# subshell. Getting that wrong does not produce a crash. It produces a suite
# that compiles 54 fixtures, loses 53 verdicts, and reports a clean run.
#
# That is this repository's characteristic failure, and it has happened here
# more than once: a sandboxed TeX run typesets nothing and passes, a stale
# artifact reads as evidence, `grep -q` loses a race to SIGPIPE, and the
# linebreak sweep once reported nine successes having measured nothing. So a
# unit that leaves no result is not absent from the tally; it is a failure, by
# name, and `fanout_account` is what makes it one.
#
# HOW A CALLER USES IT
#
#   . "$here/../lib/fanout.sh"
#
#   fanout_reset
#   for unit in "${units[@]}"; do
#     fanout_add "$unit" "run_one_unit '$unit'"
#   done
#   fanout_run "$jobs" "$scratch"
#   fanout_gather "$scratch"
#   fanout_replay "$scratch"
#   fanout_account || fail=1
#
# `run_one_unit` is an ordinary function in the calling script. Workers are
# subshells of that script, so they inherit its functions and variables; what
# they cannot do is write back. Everything a unit wants to say it says on
# stdout, and everything it wants to assert it says through its exit status.
#
# WHAT A CALLER MUST NOT ASSUME
#
# A unit's exit status is the only channel out. A unit that sets `fail=1` in a
# global and returns 0 reports a pass, and nothing here can tell. Each runner's
# per-unit function therefore has to `return 1` rather than assign, which is the
# one invasive change fanning out a runner requires.
#
# WHERE IT RUNS
#
# macOS /bin/bash 3.2 as well as modern bash: no `wait -n`, no associative
# arrays, no process substitution — intermediates go to the caller's scratch
# directory, because some sandboxed environments deny /dev/fd. The throttle
# polls `jobs -rp` for the same reason tests/layout/sweep-linebreak-parallel.sh
# and tests/check-parallel.sh do.
#
# The committed negative controls for everything below live in
# `tests/check-parallel.sh --self-test`, which drives these functions over
# synthetic units, compiles nothing, and runs in the sub-second `lint` slot.

# The input: one name and one command string per unit, filled by fanout_add.
fanout_names=()
fanout_cmds=()

# The output of fanout_gather, parallel to fanout_names.
fanout_states=()
fanout_times=()
fanout_dispatched=0
fanout_completed=0
fanout_failed=0
fanout_missing=0

# Optional. When non-empty, each worker is handed its own PAR_TMPDIR beneath it,
# so no two biber invocations share an unpacking cache; issue #392 measured why
# warming a shared one cannot substitute. Directories must already exist —
# created before dispatch, so a filesystem that cannot hold them stops the run
# with one message instead of several workers failing on a lipo error.
fanout_par_root=""

# Printed per dispatch when 1. Off by default: a runner's replayed output has to
# match what its serial path prints, and dispatch chatter would not.
fanout_verbose=0

fanout_slot() { printf '%02d-%s' "$1" "$2"; }

# fanout_warm_fonts <scratch>
#
# One small LuaLaTeX build, before any worker starts, that is required to prove
# it typeset real glyphs.
#
# LuaLaTeX needs to write luaotfload's font cache. Where it cannot, fontspec
# falls back to nullfont, every document typesets empty, and every suite passes
# having measured nothing. Serially the first compile pays the cache-warming
# cost once; under fan-out several processes race to build it at once, which is
# exactly when it goes wrong.
#
# Exit status alone does not prove it: a nullfont document compiles cleanly and
# is empty. So the log is checked for the two signatures of that state as well.
# `grep pattern file` rather than `... | grep -q`: the pipe form exits at its
# first match, hands the producer a SIGPIPE, and under `pipefail` reports "not
# found" for something that is there.
fanout_warm_fonts() {
  local scratch="$1"
  local warm="$scratch/warm"
  mkdir -p "$warm" || return 1

  if ! command -v lualatex > /dev/null 2>&1; then
    printf 'fanout: lualatex not found; this suite cannot run here.\n' >&2
    return 1
  fi

  cat > "$warm/warm.tex" <<'WARMTEX'
% Generated by tests/lib/fanout.sh. Not a fixture: it asserts nothing about the
% classes. It exists to populate luaotfload's cache for the two families
% careerdossier-typography.sty loads, before several workers race to do it.
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
    printf 'fanout: the font-cache warm-up build FAILED.\n' >&2
    printf 'Nothing was dispatched. See %s\n' "$warm/warm.stdout" >&2
    tail -20 "$warm/warm.stdout" 2>/dev/null | sed 's/^/  /' >&2
    return 1
  fi

  if [ ! -f "$warm/warm.log" ]; then
    printf 'fanout: the warm-up build wrote no log; refusing to fan out.\n' >&2
    return 1
  fi

  if grep 'metric data not found' "$warm/warm.log" > /dev/null 2>&1 \
     || grep 'nullfont' "$warm/warm.log" > /dev/null 2>&1; then
    printf 'fanout: the warm-up build typeset with NO REAL FONT.\n' >&2
    printf 'luaotfload could not use its cache, so every fixture would compile\n' >&2
    printf 'empty documents and pass. Nothing was dispatched. Run this from an\n' >&2
    printf 'ordinary interactive shell rather than a restricted sandbox.\n' >&2
    printf 'See %s\n' "$warm/warm.log" >&2
    return 1
  fi

  printf '  font cache warm (one build, real glyphs confirmed)\n'
  return 0
}

fanout_reset() {
  fanout_names=()
  fanout_cmds=()
  fanout_states=()
  fanout_times=()
  fanout_dispatched=0
  fanout_completed=0
  fanout_failed=0
  fanout_missing=0
}

# fanout_add <name> <command string>
#
# The name becomes part of a filename, so it may not carry whitespace: a name
# with a space in it would make the slot ambiguous and two units could then
# write one another's result. Rejected rather than mangled.
fanout_add() {
  case "$1" in
    '')
      printf 'fanout: a unit name may not be empty\n' >&2
      return 1
      ;;
    *[[:space:]]*|*/*)
      printf 'fanout: unit name contains whitespace or a slash: %s\n' "$1" >&2
      return 1
      ;;
  esac
  fanout_names+=("$1")
  fanout_cmds+=("$2")
  return 0
}

# fanout_run <jobs> <scratch>
#
# Dispatches every added unit, at most <jobs> in flight, and waits for all of
# them. Each worker writes its combined output to <scratch>/NN-<name>.log and
# its exit status to <scratch>/NN-<name>.status.
fanout_run() {
  local jobs="$1" scratch="$2"
  local n i name cmd slot

  n="${#fanout_names[@]}"
  fanout_dispatched="$n"
  [ "$n" -eq 0 ] && return 0

  for (( i = 0; i < n; i++ )); do
    name="${fanout_names[$i]}"
    cmd="${fanout_cmds[$i]}"
    slot="$(fanout_slot "$i" "$name")"
    [ "$fanout_verbose" -eq 1 ] \
      && printf '  dispatch [%d/%d] %s\n' "$((i + 1))" "$n" "$name"
    (
      # This worker's own biber cache, when the caller asked for one. Guarded on
      # the directory so a caller that prepared none is unaffected.
      [ -n "$fanout_par_root" ] && [ -d "$fanout_par_root/$slot" ] \
        && export PAR_TMPDIR="$fanout_par_root/$slot"
      start="$SECONDS"
      # The nested subshell is load-bearing: a unit that calls `exit` would
      # otherwise take the worker with it and skip the status write below,
      # turning an ordinary failure into a vanished worker. A runner's per-unit
      # function is ordinary shell and can do exactly that — one stray `exit 1`
      # inside an assertion helper is all it takes — and a machine that behaves
      # differently under test than in use is not evidence about the machine in
      # use.
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
  return 0
}

# fanout_gather <scratch>
#
# Reads the result files and fills fanout_states/fanout_times and the four
# counters. Prints nothing: what to say about a failure differs per caller, and
# only the counting is shared.
fanout_gather() {
  local scratch="$1"
  local n i name slot code elapsed

  n="${#fanout_names[@]}"
  fanout_states=()
  fanout_times=()
  fanout_completed=0
  fanout_failed=0
  fanout_missing=0

  for (( i = 0; i < n; i++ )); do
    name="${fanout_names[$i]}"
    slot="$(fanout_slot "$i" "$name")"
    if [ ! -f "$scratch/$slot.status" ]; then
      fanout_states+=("NO-RESULT")
      fanout_times+=("-")
      fanout_missing=$((fanout_missing + 1))
      continue
    fi
    code=""
    elapsed=""
    read -r code elapsed < "$scratch/$slot.status"
    case "$code" in
      ''|*[!0-9]*)
        # A result file that exists but does not parse is an absent result, not
        # a pass. Counted as missing so the accounting assertion sees it.
        fanout_states+=("NO-RESULT")
        fanout_times+=("-")
        fanout_missing=$((fanout_missing + 1))
        continue
        ;;
    esac
    fanout_completed=$((fanout_completed + 1))
    fanout_times+=("${elapsed:-?}")
    if [ "$code" -eq 0 ]; then
      fanout_states+=("ok")
    else
      fanout_states+=("FAILED($code)")
      fanout_failed=$((fanout_failed + 1))
    fi
  done
  return 0
}

# fanout_replay <scratch> [banner]
#
# Replays every unit's captured output in dispatch order, which is the order the
# serial path printed it. With `banner` non-empty each unit's output is wrapped
# in a `----- name (state) -----` header; without it the logs are concatenated
# bare, so a runner's replayed transcript is the transcript it would have
# produced serially.
fanout_replay() {
  local scratch="$1" banner="${2:-}"
  local n i name slot
  n="${#fanout_names[@]}"
  for (( i = 0; i < n; i++ )); do
    name="${fanout_names[$i]}"
    slot="$(fanout_slot "$i" "$name")"
    [ -n "$banner" ] \
      && printf -- '----- %s (%s) -----\n' "$name" "${fanout_states[$i]}"
    if [ -f "$scratch/$slot.log" ]; then
      cat "$scratch/$slot.log"
    else
      printf '  (no output captured; the worker left no log)\n'
    fi
    [ -n "$banner" ] && printf '\n'
  done
  return 0
}

# fanout_account [<plural noun>]
#
# The accounting assertion, and the only reason any of this is safe to believe.
# Stated as its own verdict rather than folded into a pass/fail line, because
# "nothing failed" and "everything ran" are different claims and only the second
# one is at risk under fan-out. Returns nonzero when any unit left no usable
# result, naming the ones that did not report.
#
# It deliberately says nothing about units that ran and failed: those reported
# for themselves, in their own replayed output, and the caller's own summary
# owns that verdict.
#
# The noun is plural and defaults to `targets`, which is what makes this
# byte-identical to the text tests/check-parallel.sh printed before it delegated
# here — that output is documented in docs/TESTING.md and pinned by --self-test,
# so the shared implementation has to reproduce it exactly rather than nearly.
fanout_account() {
  local noun="${1:-targets}"
  local i

  printf '\n  dispatched %d, completed %d\n' \
    "$fanout_dispatched" "$fanout_completed"

  [ "$fanout_missing" -eq 0 ] && return 0

  printf '\nACCOUNTING FAILURE: %d of %d %s left no usable result.\n' \
    "$fanout_missing" "$fanout_dispatched" "$noun"
  printf 'A worker died before it could record an outcome. These %s did\n' "$noun"
  printf 'NOT pass; they did not report:\n'
  for (( i = 0; i < "${#fanout_names[@]}"; i++ )); do
    [ "${fanout_states[$i]}" = "NO-RESULT" ] \
      && printf '  - %s\n' "${fanout_names[$i]}"
  done
  return 1
}
