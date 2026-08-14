#!/usr/bin/env bash
# run-version-declarations.sh — one version and one date across the Work (#258)
#
# WHAT THIS ASSERTS
#
# Every file of the Work identifies itself to LaTeX exactly once:
#
#   \ProvidesExplPackage {careerdossier-base} {2026-08-12} {0.8.0}
#   \ProvidesExplClass   {careerdossier-cv}   {2026-08-12} {0.8.0}
#
# Ten such declarations exist, they are bumped by hand, and until this script
# nothing compared them. A release that missed one file would pass every suite
# and ship: LaTeX writes both values into the `.log' without complaint, and no
# committed baseline records either one --
#
#   grep -l '0\.8\.0\|2026-08-12' tests/regression/*.tlg   # no output
#
# -- which is deliberate, since a baseline that pinned a version would churn on
# every release. The result is a distribution whose careerdossier-resume.cls
# says 0.8.0 while its careerdossier-theme.sty says 0.7.0, with nothing anywhere
# that is wrong enough to fail.
#
# So the four checks below, over `manifest.txt' and the root sources together:
#
#   1. every .sty/.cls the manifest lists under "The Work" exists and carries a
#      \ProvidesExpl{Package,Class} declaration;
#   2. every such declaration parses into a {date} {version} pair;
#   3. all the pairs are identical; and
#   4. the declaring files and the manifest's Work list are the same set, so a
#      source added to the Work without a manifest entry -- or a manifest entry
#      with no source -- is caught by the same pass.
#
# (4) is here because it is the same class of drift as (3) and costs nothing
# once both lists are being read; `manifest.txt' is what defines the Work for
# the LPPL, so a file missing from it is a licensing defect as well as a
# packaging one.
#
# WHAT IT DELIBERATELY DOES NOT CHECK
#
# The version against the latest git tag, and the declarations against
# `CHANGELOG.md' or `docs/MIGRATION.md'. Both legitimately disagree on `main'
# between releases -- the declarations lead or trail the tag, and the headings
# move at a different moment in the release sequence -- so either check would
# fail on a correct tree. Consistency between the ten is the property that is
# true at every commit, and it is the only one asserted here.
#
# HOW IT AVOIDS PASSING BY FINDING NOTHING
#
# Two ways, because a lint over a file list has exactly one interesting failure
# mode and it is a green one. A run that parses no Work files at all fails
# rather than reporting success, and the fixtures under fixtures/version/ pin
# one verdict each: a tree that is consistent, and one tree per way of being
# inconsistent. A checker that had stopped detecting anything fails there.
#
# The lint parses text. It runs no LaTeX, needs no TeX installation, and shares
# the sub-second `lint' slot with tests/lint/run.sh.
#
# Requirements: bash and awk. Run from anywhere.
#
# Portability, for the same reason tests/lint/run.sh carries the note: this is
# text processing, and local `grep'/`awk' are ugrep and one-true-awk while CI's
# are GNU grep and gawk or mawk. A brace is written `[{]', and nothing is piped
# into `grep -q' or `grep -c' (issue #398's ratchet); membership tests are shell
# `case' matches, which fork nothing and cannot report a hit as a miss.
set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../.." && pwd)"
fixtures="$here/fixtures/version"

# Reads the "The Work" section of a manifest and prints the .sty/.cls filenames
# it lists, one per line, in manifest order.
#
# The section runs from the `The Work' heading to the underline of whichever
# heading follows it -- the heading's own underline is the one exception, and is
# stepped over rather than read as a terminator. Anything that is not a bare
# .sty/.cls filename in the first column -- prose, blank lines, `manifest.txt'
# itself -- is ignored, which is what lets the section carry a description
# column.
#
# The underline is matched as `^---' rather than `^-{3,}$': interval expressions
# are the one ERE feature this repository's three awks do not agree on.
read -r -d '' awk_work <<'AWK'
BEGIN { inwork = 0; underline = 0 }
{
  if (!inwork) {
    if ($0 ~ /^The Work[ \t]*$/) { inwork = 1; underline = 1 }
    next
  }
  if ($0 ~ /^---/) {
    if (underline) { underline = 0; next }
    exit
  }
  if ($1 ~ /\.(sty|cls)$/) print $1
}
AWK

# Reads one source file and prints a single tab-separated record:
#
#   PARSED       <date> <version>
#   UNPARSEABLE  -     -            a \ProvidesExpl* line no pair could be read from
#   NONE         -     -            no \ProvidesExpl* line at all
#
# The two failure states are kept apart because they are different defects with
# different fixes: a typo'd argument list, versus a file that never declared
# itself. Comment lines are dropped first, so prose quoting a declaration --
# this script's own header, were it ever scanned -- cannot satisfy the check.
read -r -d '' awk_decl <<'AWK'
function trim(s) { sub(/^[ \t]+/, "", s); sub(/[ \t]+$/, "", s); return s }
BEGIN { seen = 0; parsed = 0 }
{
  line = $0
  sub(/^[ \t]+/, "", line)
  if (line ~ /^%/) next
  if (line !~ /\\ProvidesExpl(Package|Class)/) next
  seen = 1
  if (match(line, /\\ProvidesExpl(Package|Class)[ \t]*[{][^{}]*[}][ \t]*[{][^{}]*[}][ \t]*[{][^{}]*[}]/)) {
    seg = substr(line, RSTART, RLENGTH)
    split(seg, parts, /[{}]/)
    printf "PARSED\t%s\t%s\n", trim(parts[4]), trim(parts[6])
    parsed = 1
    exit
  }
}
END {
  if (parsed) exit
  if (seen) print "UNPARSEABLE\t-\t-"
  else print "NONE\t-\t-"
}
AWK

# Checks one tree: a directory holding a manifest and the sources it lists.
# Prints one status line per file, plus a detail line naming the fix for each
# failure. Returns 1 on any failure; the number of Work files seen is left in
# $work_seen.
work_seen=0
lint_tree() {
  local dir="$1"
  local manifest="$dir/manifest.txt"
  local work files decl state date version file base
  local reference_date="" reference_version="" bad=0

  if [ ! -f "$manifest" ]; then
    printf '  %-28s %s\n' "$(basename "$dir")" "NO MANIFEST"
    printf '    -> %s\n' "expected a manifest at $manifest"
    return 1
  fi

  work="$(awk "$awk_work" "$manifest")"

  # Every root source's declaration, whether or not the manifest lists it.
  # Recorded before any verdict, because the reference pair is derived from the
  # Work files and the set comparison needs the others.
  files=""
  for file in "$dir"/*.sty "$dir"/*.cls; do
    [ -f "$file" ] || continue
    base="$(basename "$file")"
    decl="$(awk "$awk_decl" "$file")"
    files="$files$base	$decl
"
  done

  # The reference pair is the commonest one among the Work files, not the first
  # one: a single mistyped file should be named as the outlier rather than
  # making the nine correct files the outliers.
  local pairs
  pairs="$(printf '%s' "$files" | CDOSSIER_WORK="$work" awk -F'\t' '
    BEGIN {
      n = split(ENVIRON["CDOSSIER_WORK"], w, "\n")
      for (i = 1; i <= n; i++) if (w[i] != "") inwork[w[i]] = 1
    }
    $2 == "PARSED" && ($1 in inwork) {
      key = $3 "\t" $4
      if (!(key in count)) order[++seen] = key
      count[key]++
    }
    END {
      best = ""; bestn = -1
      for (i = 1; i <= seen; i++) if (count[order[i]] > bestn) { bestn = count[order[i]]; best = order[i] }
      if (best != "") print best
    }')"
  reference_date="$(printf '%s' "$pairs" | cut -f1)"
  reference_version="$(printf '%s' "$pairs" | cut -f2)"

  # With no parseable declaration anywhere there is no reference to quote, and
  # a message reading `declaring { } { }' would look like the lint's own bug
  # rather than the tree's. Say what is true instead.
  local reference="{ $reference_date } { $reference_version }"
  [ -n "$reference_version" ] || reference="the version and date the rest of the Work carries"

  # Direction 1: every file the manifest calls part of the Work.
  local line status detail
  while IFS= read -r base; do
    [ -n "$base" ] || continue
    work_seen=$((work_seen + 1))
    status="OK"
    detail=""
    version=""
    date=""
    if [ ! -f "$dir/$base" ]; then
      status="MISSING FILE"
      detail="manifest.txt lists $base under \"The Work\", but no such file exists"
    else
      line="$(printf '%s' "$files" | awk -F'\t' -v b="$base" '$1 == b { print; exit }')"
      state="$(printf '%s' "$line" | cut -f2)"
      date="$(printf '%s' "$line" | cut -f3)"
      version="$(printf '%s' "$line" | cut -f4)"
      case "$state" in
        NONE)
          status="NO DECLARATION"
          detail="add \\ProvidesExplPackage or \\ProvidesExplClass to $base, declaring $reference"
          ;;
        UNPARSEABLE)
          status="UNPARSEABLE DECLARATION"
          detail="$base declares itself but no { date } { version } pair could be read; the form is \\ProvidesExpl{Package,Class} {name} {date} {version}"
          ;;
        *)
          if [ "$version" != "$reference_version" ]; then
            status="VERSION MISMATCH"
            detail="$base declares { $date } { $version }; the rest of the Work declares $reference"
          elif [ "$date" != "$reference_date" ]; then
            status="DATE MISMATCH"
            detail="$base declares { $date } { $version }; the rest of the Work declares $reference"
          fi
          ;;
      esac
    fi
    printf '  %-28s %-24s %s\n' "$base" "$status" "${version:-}"
    if [ -n "$detail" ]; then
      printf '    -> %s\n' "$detail"
      bad=1
    fi
  done <<EOF
$work
EOF

  # Direction 2: every declaring source the manifest does not list. A file that
  # identifies itself to LaTeX as part of this bundle either belongs to the
  # Work or should stop saying so.
  local nl='
'
  while IFS="$(printf '\t')" read -r base state _ _; do
    [ -n "$base" ] || continue
    [ "$state" = "NONE" ] && continue
    case "$nl$work$nl" in
      *"$nl$base$nl"*) continue ;;
    esac
    printf '  %-28s %-24s\n' "$base" "NOT IN MANIFEST"
    printf '    -> %s\n' "$base declares itself with \\ProvidesExpl* but is absent from manifest.txt \"The Work\"; add it there or remove the declaration"
    bad=1
  done <<EOF
$files
EOF

  return "$bad"
}

fail=0

echo "== version and date across the Work =="
lint_tree "$root" || fail=1

if [ "$work_seen" -eq 0 ]; then
  echo "  NO WORK FILES FOUND — the lint is not matching anything"
  fail=1
else
  echo "  $work_seen Work files checked"
fi

# Self-check. One tree per verdict, so a checker that stopped detecting a
# mismatch — or started rejecting a consistent tree — fails here.
echo
echo "== fixtures (the lint's own failure modes) =="
self_check() {
  local tree="$1" expected="$2" out rc
  out="$(work_seen=0; lint_tree "$fixtures/$tree")"
  rc=$?
  if [ "$expected" = "OK" ]; then
    if [ "$rc" -ne 0 ]; then
      echo "  $tree EXPECTED PASS but the lint reported:"
      printf '%s\n' "$out" | sed 's/^/    /'
      fail=1
    else
      echo "  $tree accepted as intended"
    fi
    return
  fi
  if [ "$rc" -eq 0 ]; then
    echo "  $tree EXPECTED FAILURE but the lint passed it"
    fail=1
    return
  fi
  # Issue #398: three states. A check that could not run is not a report about
  # the lint's message.
  case "$out" in
    '')
      echo "  $tree PRODUCED NO CHECKABLE OUTPUT: '$expected' was never looked"
      echo "    for, so the rejection has not been shown to be the intended one."
      fail=1
      ;;
    *"$expected"*) echo "  $tree rejected as intended ($expected)" ;;
    *)
      echo "  $tree FAILED for the wrong reason: expected '$expected', got:"
      printf '%s\n' "$out" | sed 's/^/    /'
      fail=1
      ;;
  esac
}

self_check consistent          "OK"
self_check version-mismatch    "VERSION MISMATCH"
self_check date-mismatch       "DATE MISMATCH"
self_check no-declaration      "NO DECLARATION"
self_check unparseable         "UNPARSEABLE DECLARATION"
self_check missing-file        "MISSING FILE"
self_check not-in-manifest     "NOT IN MANIFEST"

echo
if [ "$fail" -eq 0 ]; then
  echo "VERSION DECLARATION LINT PASSED"
else
  echo "VERSION DECLARATION LINT FAILED"
fi
exit "$fail"
