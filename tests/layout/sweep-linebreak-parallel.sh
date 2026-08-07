#!/usr/bin/env bash
# sweep-linebreak-parallel.sh — run sweep-linebreak.sh's arms concurrently.
#
# WHAT THIS IS
#
# A driver, not a second instrument. It runs `sweep-linebreak.sh` once per
# candidate value, several at a time, each into its own scratch directory via
# that script's `--output`, then merges the per-value results back into
# build/linebreak-sweep/ so the output is indistinguishable from a serial run.
# Every measurement is made by sweep-linebreak.sh; nothing here touches how a
# number is produced, only how many sweeps are in flight at once.
#
# WHY IT EXISTS
#
# A sweep costs one LuaLaTeX build per fixture per body size per margin, per
# value. The fixture corpus is 36 discovered fixtures x 3 sizes x 2 margins =
# 216 builds for ONE value; the nine-arm sweep that produced the
# \CDossierEmergencyStretch table in docs/ARCHITECTURE.md is 1,944 builds.
# Serially that is ~35-40 minutes at ~0.9s per build. sweep-linebreak.sh is
# deliberately single-threaded -- the right default for the one- or two-value
# checks that are the common case -- so this exists for the large runs.
#
# Parallelism is ACROSS VALUES, not within one. Each sub-sweep is serial
# internally, so more workers than values buys nothing: with 9 values, `--jobs
# 12` behaves exactly like `--jobs 9`.
#
# WHERE IT RUNS
#
# Written for POSIX-ish shells and tested on macOS. Two portability notes:
#
#   - It avoids `wait -n`, which needs bash >= 4.3. macOS still ships bash 3.2
#     as /bin/bash, so the worker throttle polls `jobs -rp` instead. That costs
#     a second or two of latency per slot and nothing else.
#   - It avoids process substitution for comparisons and writes intermediates to
#     the scratch directory, because some sandboxed environments deny /dev/fd.
#
# It needs whatever sweep-linebreak.sh needs: lualatex and pdftotext for either
# corpus, pdfinfo for page counts, and latexmk plus biber for the bibliography
# example in the `examples` corpus.
#
# IT WILL NOT WORK CORRECTLY UNDER A RESTRICTED SANDBOX. LuaLaTeX needs to write
# luaotfload's font cache; where it cannot, fontspec silently falls back to
# nullfont, every document typesets as empty, and the sweep reports a clean run
# with zero overfull boxes everywhere. That failure looks exactly like success.
# Run this from an ordinary interactive shell. If a whole sweep comes back with
# implausibly low counts, check a .log in the scratch directory for
# "not loadable: metric data not found or bad" before believing it.
#
# Nothing here is part of `make check`. Like `review-page-two` and
# `review-matrix`, it produces evidence a human reads. Its output under
# build/linebreak-sweep/ is generated and gitignored.
#
# USAGE
#
#   tests/layout/sweep-linebreak-parallel.sh [--jobs N] [--param NAME] \
#       [--values "V1 V2 ..."] [--corpus WHICH]
#
#   --jobs     concurrent sweeps; default 4, which suits a 4-performance-core
#              machine. Capped at the number of values.
#   --param    passed through to sweep-linebreak.sh
#   --values   passed through; one sweep is run per entry
#   --corpus   passed through (fixtures | examples | both)
#
#   --merge-only DIR
#              skip all measurement and merge an existing scratch directory
#              from an earlier run. Recovery for the case where every sweep
#              succeeded but the merge step failed -- 1,944 builds are worth
#              not repeating. DIR is the "Per-value console output kept at:"
#              path the failed run printed.
#
# EXAMPLE — the nine-arm emergencystretch sweep behind ARCHITECTURE.md's
# derived-metrics table. Note the single quotes: a value naming a length
# register carries a backslash the shell would otherwise eat.
#
#   tests/layout/sweep-linebreak-parallel.sh --jobs 4 \
#     --corpus fixtures --param emergencystretch \
#     --values '0pt 1.50\CDossierBodySize 2.00\CDossierBodySize 2.50\CDossierBodySize 0.030\textwidth 0.035\textwidth 0.040\textwidth 0.045\textwidth 0.050\textwidth'
set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../.." && pwd)"
sweep="$here/sweep-linebreak.sh"
final="$root/build/linebreak-sweep"

jobs=4
param=""
values=""
corpus=""
merge_only=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --jobs)       jobs="${2:?--jobs needs a number}"; shift 2 ;;
    --param)      param="${2:?--param needs a value}"; shift 2 ;;
    --values)     values="${2:?--values needs a value}"; shift 2 ;;
    --corpus)     corpus="${2:?--corpus needs a value}"; shift 2 ;;
    --merge-only) merge_only="${2:?--merge-only needs a directory}"; shift 2 ;;
    -h|--help)    sed -n '2,80p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
done

[ -x "$sweep" ] || { echo "cannot execute $sweep" >&2; exit 1; }

# Merging is shared by the normal path and by --merge-only, so a recovery merge
# cannot drift from the merge a successful run performs.
merge_scratch() { # scratch-dir
  local scratch="$1" d v fail=0 merged=0 allvalues=""
  echo "merging results from $scratch into $final"
  mkdir -p "$final"
  find "$final" -maxdepth 1 -type f -name '*.tsv' -delete
  find "$final" -maxdepth 1 -type f -name '*.txt' -delete

  for d in "$scratch"/*/; do
    [ -d "$d" ] || continue
    if ! ls "$d"*.tsv >/dev/null 2>&1; then
      echo "  MISSING RESULT in $d -- see ${d}log.txt"
      tail -3 "${d}log.txt" 2>/dev/null | sed 's/^/      /'
      fail=1
      continue
    fi
    cp "$d"*.tsv "$final/"
    merged=$((merged + 1))
    v="$(sed -n 's/^values: //p' "${d}sweep-record.txt" 2>/dev/null | head -1)"
    allvalues="$allvalues $v"
  done

  {
    echo "# CareerDossierTeX line-breaking sweep (issue #316), parallel run"
    echo "commit: $(git -C "$root" rev-parse HEAD 2>/dev/null || echo unavailable)"
    echo "values:$allvalues"
    echo
    echo "Per-document rows are in the .tsv files beside this record, one per"
    echo "value, with columns:"
    echo "  document  overfull  hyphens  loose  worst  third  pages"
    echo
    echo "A fixture-corpus document is named <fixture>--<size>pt-<margin>, which"
    echo "is what makes a specific overflowing cell identifiable rather than"
    echo "merely countable."
    echo
    echo "Value -> artifact filename:"
    for d in "$scratch"/*/; do
      [ -d "$d" ] || continue
      # Each per-value record repeats the same two-line lead sentence before its
      # mapping; skip both so the merged record does not restate it per value.
      grep -A20 '^Value -> artifact filename' "${d}sweep-record.txt" 2>/dev/null \
        | tail -n +3 | sed '/^$/d'
    done
  } > "$final/sweep-record.txt"

  echo
  if [ "$fail" -eq 0 ]; then
    echo "MERGED $merged value(s) into $final"
  else
    echo "SOME VALUES MISSING -- see above. Nothing was re-run; the scratch"
    echo "directory is intact and can be merged again once the cause is fixed."
  fi
  return "$fail"
}

if [ -n "$merge_only" ]; then
  [ -d "$merge_only" ] || { echo "no such directory: $merge_only" >&2; exit 1; }
  merge_scratch "$merge_only"
  exit "$?"
fi

[ -n "$values" ] || { echo "--values is required (or use --merge-only)" >&2; exit 2; }

# Build the pass-through argument list once. An empty --param/--corpus is
# omitted so sweep-linebreak.sh applies its own documented defaults rather than
# receiving an empty string.
passthrough=()
[ -n "$param" ]  && passthrough+=(--param "$param")
[ -n "$corpus" ] && passthrough+=(--corpus "$corpus")

# Word-split $values the same way sweep-linebreak.sh does, so an entry means the
# same thing in both places.
value_list=()
for v in $values; do value_list+=("$v"); done
[ "$jobs" -gt "${#value_list[@]}" ] && jobs="${#value_list[@]}"

scratch="$(mktemp -d "${TMPDIR:-/tmp}/careerdossier-parallel-sweep.XXXXXX")"

echo "Running ${#value_list[@]} value(s), $jobs at a time, into $scratch"
echo "(each value is one full sweep of the selected corpus)"
echo

i=0
for v in "${value_list[@]}"; do
  i=$((i + 1))
  dir="$scratch/$i"
  mkdir -p "$dir"
  (
    # Report what actually happened, at three levels. An unconditional "done"
    # here once hid a run in which every sweep failed instantly on a bad path
    # and nothing was measured at all, while the driver reported nine
    # successes -- so each level below exists because its absence produced a
    # confident, wrong result.
    #
    #   1. the sweep exited non-zero
    #   2. it exited 0 but wrote no .tsv
    #   3. it wrote a .tsv in which EVERY row is BUILD-FAILED. A value TeX
    #      rejects (a malformed dimension, say) does not stop the sweep: every
    #      document fails to build, the rows are all BUILD-FAILED, and the
    #      arm's totals come out as clean zeroes. That reads as a perfect
    #      result unless it is checked for here.
    if ! "$sweep" "${passthrough[@]}" --values "$v" --output "$dir" \
           > "$dir/log.txt" 2>&1; then
      echo "  [$i/${#value_list[@]}] FAILED: $v (sweep exited non-zero) -- see $dir/log.txt"
      tail -3 "$dir/log.txt" 2>/dev/null | sed 's/^/        /'
    elif ! ls "$dir"/*.tsv >/dev/null 2>&1; then
      echo "  [$i/${#value_list[@]}] FAILED: $v (no results written) -- see $dir/log.txt"
      tail -3 "$dir/log.txt" 2>/dev/null | sed 's/^/        /'
    elif awk -F'\t' '{tot++; if ($2 == "BUILD-FAILED") bad++}
                     END {exit (tot > 0 && bad == tot) ? 0 : 1}' "$dir"/*.tsv; then
      echo "  [$i/${#value_list[@]}] FAILED: $v (every document failed to build --"
      echo "        is the value valid for --param $param?) -- see $dir/*.tsv"
    else
      echo "  [$i/${#value_list[@]}] done: $v"
    fi
  ) &

  # Throttle without `wait -n` (bash >= 4.3 only; macOS /bin/bash is 3.2).
  while [ "$(jobs -rp | wc -l | tr -d ' ')" -ge "$jobs" ]; do
    sleep 2
  done
done

wait
echo

merge_scratch "$scratch"
status="$?"
echo "Per-value console output kept at: $scratch"
echo "(safe to delete once the merged results look right)"
exit "$status"
