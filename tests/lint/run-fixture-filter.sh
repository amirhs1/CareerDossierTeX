#!/usr/bin/env bash
# run-fixture-filter.sh — CareerDossierTeX suite fixture-selection contract
#
# `make smoke`, `make layout`, `make extract-test`, and `make tagging` take an
# optional `FIXTURE=<pattern>` that scopes the run to the fixtures matching it
# (issues #359 and #367). That selection is the one part of a test runner whose
# own failure mode is a *pass*: a suite that selects nothing makes none of its
# assertions and reports every one of them clean. This script is what stops that
# being silent.
#
# For each scopable runner it asserts:
#
#   1. `--list` with no pattern names the runner's whole fixture universe and
#      nothing else — in both directions, so an entry added without a fixture or
#      a fixture added without an entry is caught here rather than at the next
#      full run. The universe has two shapes and each gets the check that can
#      actually fail for it:
#
#      `file'  — one selectable name per *.tex in the directory. Equality with
#               the directory listing is the assertion. Real work for the smoke
#               runner, whose universe is a hand-written `cases' array.
#
#      `group' — tests/tagging only. Its selectable unit is the fixture *group*,
#               because a group's `-untagged' and `-ua2' companions are checked
#               against the base fixture (check_untagged and
#               check_visual_equivalence are claims about the pair) and mean
#               nothing selected apart from it. So 12 groups are backed by 37
#               .tex files and the `file' form above would assert something
#               false.
#
#               The obvious substitute is also wrong, and is written down here
#               so it is not rediscovered: deriving the groups from the
#               `*-body.inc.tex' files yields 10, not 12, because
#               `resume-displaydoctitle-off' shares no body with a sibling and
#               `biblatex-ua2' is a standalone feasibility fixture. A universe
#               check built that way would under-count by two and pass —
#               precisely the shape of bug it exists to catch.
#
#               What is true of all 12 is that each owns a `<group>.tex`. So the
#               mapping is asserted in both directions: every listed group has
#               its own .tex, and every .tex resolves to exactly one listed group
#               — as that group's own file or as one of its `-untagged',
#               `-ua2', or `-body.inc' companions. A group added without files,
#               a file added without a group, and a name that resolves two ways
#               all fail.
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

# Membership without a pipe. `printf ... | grep -q' would exit at the first
# match, hand the producer a SIGPIPE, and under `pipefail' report the pipeline
# as failed — a "not found" for something that is there. Every membership test
# below therefore walks an array.
listed_groups=()
group_is_listed() {
  local candidate
  for candidate in ${listed_groups[@]+"${listed_groups[@]}"}; do
    [ "$candidate" = "$1" ] && return 0
  done
  return 1
}

listed_units=()
unit_is_listed() {
  local candidate
  for candidate in ${listed_units[@]+"${listed_units[@]}"}; do
    [ "$candidate" = "$1" ] && return 0
  done
  return 1
}

# The `group' universe check: the tagging runner's selectable groups against the
# .tex files backing them, asserted in both directions. See the header for why
# equality with the directory listing cannot be the assertion here.
check_group_universe() {
  local dir="$1"
  local bad=0 name base suffix remainder file
  local resolved

  for name in ${listed_groups[@]+"${listed_groups[@]}"}; do
    if [ ! -f "$dir/$name.tex" ]; then
      echo "      selectable group with no $name.tex: $name"
      bad=1
    fi
  done

  for file in "$dir"/*.tex; do
    base="$(basename "$file" .tex)"
    resolved=()
    for suffix in -untagged -ua2 -body.inc; do
      case "$base" in
        *"$suffix")
          remainder="${base%"$suffix"}"
          group_is_listed "$remainder" && resolved+=("$remainder")
          ;;
      esac
    done
    group_is_listed "$base" && resolved+=("$base")

    if [ "${#resolved[@]}" -eq 0 ]; then
      echo "      fixture file belongs to no selectable group: $base.tex"
      bad=1
    elif [ "${#resolved[@]}" -gt 1 ]; then
      echo "      $base.tex resolves to ${#resolved[@]} groups (${resolved[*]}): ambiguous"
      bad=1
    fi
  done

  return "$bad"
}

# suite | a pattern that must match at least one but not all of its fixtures
#       | universe shape: `file' (one selectable name per .tex) or `group'
suites=(
  "smoke|bad-medium|file"
  "layout|two-page|file"
  "extraction|statement|file"
  "tagging|cv-subsection|group"
)

for spec in "${suites[@]}"; do
  IFS='|' read -r suite pattern universe <<EOF
$spec
EOF
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

  # 1. The unfiltered universe agrees with the fixture files on disk, in the
  #    form that can actually fail for this runner's universe shape.
  listed="$("$runner" --list)"
  listed_sorted="$(printf '%s\n' "$listed" | sort)"
  listed_groups=()
  while IFS= read -r name; do
    [ -n "$name" ] && listed_groups+=("$name")
  done <<EOF
$listed
EOF

  if [ "$universe" = group ]; then
    universe_out="$(check_group_universe "$root/tests/$suite")"
    rc=$?
    if [ "$rc" -eq 0 ]; then
      n_files="$(cd "$root/tests/$suite" && ls *.tex | wc -l | tr -d '[:space:]')"
      echo "  --list names all ${#listed_groups[@]} fixture groups, backed by all $n_files .tex files"
    else
      echo "  UNIVERSE MISMATCH: --list and tests/$suite/*.tex disagree."
      printf '%s\n' "$universe_out"
      fail=1
    fi
  else
    # The `file' shape: the selectable names are exactly the *.tex basenames.
    # A heredoc terminator has to sit at column 0, which is why the `EOF' lines
    # below are not indented with the loops that read them.
    ondisk="$(cd "$root/tests/$suite" && for f in *.tex; do echo "${f%.tex}"; done)"
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

  # 6. Fan-out (issue #390): where a runner has a `--jobs' path, the units it
  #    would dispatch must cover the serial universe exactly.
  #
  #    This is the one assertion the checks above cannot make. They establish
  #    that `--list' agrees with the fixture files on disk; none of them looks
  #    at what the *parallel* driver would actually run. A runner whose fan-out
  #    silently dispatched a subset would pass every check above and then report
  #    a clean run of something other than the suite — the same shape of failure
  #    as a pattern that selects nothing, one layer further in. Compiles
  #    nothing, like everything else here.
  if grep -qE -- '--list-units\)[[:space:]]*list_units_only=1' "$runner"; then
    listed_units=()
    while IFS= read -r name; do
      [ -n "$name" ] && listed_units+=("$name")
    done <<EOF
$("$runner" --list-units)
EOF
    unit_bad=0
    for name in ${listed_groups[@]+"${listed_groups[@]}"}; do
      if ! unit_is_listed "$name"; then
        echo "      fixture never dispatched under --jobs: $name"
        unit_bad=1
      fi
    done
    # An extra unit is allowed only when it is named for a listed fixture — an
    # auxiliary check like smoke's docs/API.md drift comparison, which is not a
    # fixture compile but belongs to one. A unit named for nothing is a unit no
    # reader of `--list' knows runs.
    for name in ${listed_units[@]+"${listed_units[@]}"}; do
      group_is_listed "$name" && continue
      owned=0
      for base in ${listed_groups[@]+"${listed_groups[@]}"}; do
        case "$name" in "$base"-*) owned=1; break ;; esac
      done
      if [ "$owned" -eq 0 ]; then
        echo "      dispatched unit belongs to no listed fixture: $name"
        unit_bad=1
      fi
    done
    if [ "$unit_bad" -eq 0 ]; then
      echo "  --jobs dispatches all ${#listed_groups[@]} fixtures as ${#listed_units[@]} units"
    else
      echo "  DISPATCH MISMATCH: the serial and parallel paths select"
      echo "    different fixtures."
      fail=1
    fi
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
for suite in smoke layout extraction tagging; do
  # tests/extraction/run.sh is reached through the `extract-test' target.
  #
  # The recipe line is extracted first and then examined with `case', rather
  # than matched whole with one `grep -F'. A whole-line match was what this did
  # until the JOBS pass-through joined the recipe (issue #390), and it broke on
  # a change that was correct — a literal match asserts the argument list's
  # exact text, which is more than the contract needs and less than it means.
  # `case' also avoids the `printf | grep -q' form, whose SIGPIPE race under
  # `pipefail' reports "not found" for something that is there.
  recipe="$(grep -F "${tab}tests/$suite/run.sh" "$makefile" | head -1)"
  if [ -z "$recipe" ]; then
    echo "  tests/$suite/run.sh is not invoked from the Makefile at all"
    fail=1
    continue
  fi
  case "$recipe" in
    *'"$(FIXTURE)"'*)
      echo "  tests/$suite/run.sh receives \"\$(FIXTURE)\"" ;;
    *)
      echo "  tests/$suite/run.sh is not invoked with \"\$(FIXTURE)\" in the Makefile"
      fail=1 ;;
  esac
  # Where the runner has a fan-out path, the Makefile must be able to reach it,
  # for the same reason FIXTURE is asserted here: a recipe that dropped its
  # variable leaves every other check passing while `make smoke JOBS=4' quietly
  # runs serially — slow, not wrong, and therefore easy to never notice.
  if grep -qE -- '--list-units\)[[:space:]]*list_units_only=1' \
       "$root/tests/$suite/run.sh"; then
    case "$recipe" in
      *'$(if $(JOBS),--jobs $(JOBS))'*)
        echo "  tests/$suite/run.sh receives \$(JOBS)" ;;
      *)
        echo "  tests/$suite/run.sh has a --jobs path the Makefile cannot reach"
        fail=1 ;;
    esac
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
