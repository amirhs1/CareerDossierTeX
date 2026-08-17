#!/usr/bin/env bash
# run-manual-examples.sh — the manual's published templates are all compiled
# (issue #458)
#
# `doc/careerdossier.tex' "Complete examples" publishes complete documents a
# reader is expected to copy. A published template is a promise that the code in
# it runs, and the only thing that keeps that promise is a fixture holding that
# exact text and compiling it.
#
# WHAT IT ASSERTS
#
# The chapter's complete documents and `tests/smoke/manual-example-*.tex' are in
# **bijection**:
#
#   1. every complete document in the chapter equals exactly one fixture body;
#   2. every fixture body equals exactly one complete document;
#   3. the two sets therefore have the same size.
#
# A block counts as a complete document when it declares a class *and* opens a
# document environment. Fragments illustrating one command are neither and are
# out of scope -- they cannot be compiled as they stand.
#
# WHY A SET ASSERTION, AND WHY HERE
#
# #252 and #450 each guard one published template, and each names its block by
# content -- right when a document publishes one. #450 found this chapter
# uncovered *because* of that shape: the #252 control names the block containing
# \CDossierHeaderBegin, so the seven documents here were matched by nothing, and
# nothing said so. An example no selector names reads exactly like an example
# that does not exist. Seven more hand-kept selectors would reproduce the defect
# the moment an eighth example is added, so this asserts the sets correspond
# instead: a new example without a fixture fails here.
#
# It lives in `lint' rather than in the smoke runner for two reasons. It is a
# claim about text, and needs no TeX -- so it belongs in the sub-second lint slot
# and on the TeX-free CI lint runner, where it reports drift before any compile
# is paid for. And it is owned by no single fixture, which
# `tests/lint/run-fixture-filter.sh' correctly refuses to let a smoke *unit* be:
# a dispatched unit must be named for a listed fixture, and this one would be
# named for seven. The per-fixture compiles stay in smoke, where they belong.
#
# Matching is by exact text rather than by name or order, so renaming a fixture,
# reordering the chapter, or rewording the prose between blocks breaks nothing.
#
# Requirements: bash, awk, and cmp. Run from anywhere. Portability, as in the
# sibling lints: local `grep' is ugrep and CI's is GNU, local `awk' is
# one-true-awk and CI's is gawk or mawk, so all parsing is awk with POSIX
# regexes. Run under bash, not zsh -- zsh does not word-split unquoted
# expansions.
set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../.." && pwd)"

# Output guards that answer "could not check" apart from "absent" (issue #398).
. "$root/tests/lib/text.sh"

manual="$root/doc/careerdossier.tex"
smoke="$root/tests/smoke"
work="$root/build/manual-examples"
fail=0

# ---------------------------------------------------------------------------
# One awk program: every complete-document block in the chapter, one file each,
# plus the count on stdout.
# ---------------------------------------------------------------------------
extract_blocks() {
  awk -v outdir="$2" '
    /^\\section\{Complete examples\}/ { inchapter = 1; next }
    inchapter && /^\\section\{/       { inchapter = 0 }
    !inchapter                        { next }
    /^\\begin\{latexcode\}$/          { inblock = 1; buf = ""; next }
    inblock && /^\\end\{latexcode\}$/ {
        inblock = 0
        if (buf ~ /documentclass/ && buf ~ /begin\{document\}/) {
          n++; f = outdir "/block-" n ".tex"; printf "%s", buf > f; close(f)
        }
        next
      }
    inblock                           { buf = buf $0 "\n" }
    END                               { print n+0 }
  ' "$1"
}

# A fixture's body is everything from its first \documentclass on; the lines
# above it are the header comment explaining what the file is for.
fixture_body() {
  awk '/^\\documentclass/ { p = 1 } p' "$1"
}

check_tree() {
  local manual_file="$1" smoke_dir="$2" label="$3"
  local blocks fixtures n_blocks n_fixtures fixture body matched bad=0

  blocks="$work/$label"
  rm -rf "$blocks"
  mkdir -p "$blocks" || {
    echo "  CANNOT CREATE $blocks — nothing was compared, so this is not"
    echo "    evidence that the manual and its fixtures agree"
    return 1
  }

  n_blocks="$(extract_blocks "$manual_file" "$blocks")"

  fixtures=()
  for fixture in "$smoke_dir"/manual-example-*.tex; do
    [ -e "$fixture" ] || continue
    fixtures+=("$fixture")
  done
  n_fixtures="${#fixtures[@]}"

  # Zero blocks is a failure, not a pass over an empty set: a chapter this
  # cannot find an example in reads exactly like a chapter that stopped
  # publishing one. That is #398's shape, and the sibling smoke controls refuse
  # it for the same reason.
  if [ "$n_blocks" -eq 0 ]; then
    echo "  NO COMPLETE DOCUMENT FOUND in \"Complete examples\";"
    echo "    the shape this reads has changed, so nothing was compared"
    return 1
  fi

  if [ "$n_blocks" != "$n_fixtures" ]; then
    echo "  SET MISMATCH: the chapter publishes $n_blocks complete documents,"
    echo "    and tests/smoke/ holds $n_fixtures manual-example-*.tex fixtures"
    bad=1
  fi

  for fixture in ${fixtures[@]+"${fixtures[@]}"}; do
    body="$blocks/$(basename "$fixture" .tex).body"
    fixture_body "$fixture" > "$body"
    matched=0
    for b in "$blocks"/block-*.tex; do
      [ -e "$b" ] || continue
      if cmp -s "$body" "$b"; then
        matched=$(( matched + 1 ))
        mv "$b" "$b.claimed"
      fi
    done
    if [ "$matched" -ne 1 ]; then
      echo "  DRIFTED: $(basename "$fixture") matches $matched published examples, expected 1"
      bad=1
    fi
  done

  # Anything still unclaimed is a published example no fixture holds. The count
  # check above usually catches this first; this names *which*, which is what a
  # reader needs in order to act.
  for b in "$blocks"/block-*.tex; do
    [ -e "$b" ] || continue
    echo "  UNCOVERED: a published example that no fixture holds, opening:"
    echo "    $(head -1 "$b")"
    bad=1
  done

  [ "$bad" -eq 0 ] && echo "  $n_blocks published examples, $n_fixtures fixtures, in bijection"
  return "$bad"
}

echo "== every complete example the manual publishes is compiled =="
check_tree "$manual" "$smoke" tree || fail=1
echo

# ---------------------------------------------------------------------------
# The lint's own failure modes, so a lint that had stopped detecting anything
# fails here rather than passing everything. Each fixture pairs a manual with a
# fixture directory and states the verdict it must produce.
# ---------------------------------------------------------------------------
echo "== fixtures (the lint's own failure modes) =="
fx="$root/build/manual-examples-selftest"
rm -rf "$fx"
mkdir -p "$fx" || { echo "cannot create $fx" >&2; exit 2; }

# A minimal manual carrying two complete documents and one fragment. The
# fragment is the control for rule 3: it must not be counted.
make_manual() {
  cat > "$1" <<'MANUAL'
\section{Complete examples}

\subsection{One}

\begin{latexcode}
\documentclass{careerdossier-resume}
\begin{document}
One.
\end{document}
\end{latexcode}

A fragment, which is not a complete document and must not be counted:

\begin{latexcode}
\CDossierSection{Experience}
\end{latexcode}

\subsection{Two}

\begin{latexcode}
\documentclass{careerdossier-cv}
\begin{document}
Two.
\end{document}
\end{latexcode}

\section{Further reading}
MANUAL
}

make_fixture() {
  printf '%% header comment\n%s' "$2" > "$1"
}

expect() {
  local want="$1" label="$2" manual_file="$3" smoke_dir="$4" got
  if check_tree "$manual_file" "$smoke_dir" "selftest-$label" > "$fx/$label.out" 2>&1
  then got=pass; else got=fail; fi
  if [ "$got" = "$want" ]; then
    printf '  %-28s %s as intended\n' "$label" "$got"
  else
    printf '  %-28s EXPECTED %s, GOT %s\n' "$label" "$want" "$got"
    sed 's/^/      /' "$fx/$label.out"
    fail=1
  fi
}

one=$'\\documentclass{careerdossier-resume}\n\\begin{document}\nOne.\n\\end{document}\n'
two=$'\\documentclass{careerdossier-cv}\n\\begin{document}\nTwo.\n\\end{document}\n'

# 1. Both examples held, exactly: passes, and the fragment is not counted.
mkdir -p "$fx/ok"; make_manual "$fx/manual.tex"
make_fixture "$fx/ok/manual-example-one.tex" "$one"
make_fixture "$fx/ok/manual-example-two.tex" "$two"
expect pass complete-set "$fx/manual.tex" "$fx/ok"

# 2. An example published with no fixture: the #458 defect itself.
mkdir -p "$fx/missing"
make_fixture "$fx/missing/manual-example-one.tex" "$one"
expect fail example-without-fixture "$fx/manual.tex" "$fx/missing"

# 3. A fixture holding text the manual no longer publishes.
mkdir -p "$fx/stale"
make_fixture "$fx/stale/manual-example-one.tex" "$one"
make_fixture "$fx/stale/manual-example-two.tex" "$two"
make_fixture "$fx/stale/manual-example-gone.tex" \
  $'\\documentclass{careerdossier-letter}\n\\begin{document}\nGone.\n\\end{document}\n'
expect fail fixture-without-example "$fx/manual.tex" "$fx/stale"

# 4. One published example edited without its fixture: plain drift.
mkdir -p "$fx/drift"
make_fixture "$fx/drift/manual-example-one.tex" \
  $'\\documentclass{careerdossier-resume}\n\\begin{document}\nEdited.\n\\end{document}\n'
make_fixture "$fx/drift/manual-example-two.tex" "$two"
expect fail drifted-text "$fx/manual.tex" "$fx/drift"

# 5. A manual whose chapter this cannot find: must fail, never pass over an
#    empty set (#398).
sed 's/^\\section{Complete examples}$/\\section{Worked examples}/' \
  "$fx/manual.tex" > "$fx/manual-renamed.tex"
expect fail chapter-not-found "$fx/manual-renamed.tex" "$fx/ok"

echo
if [ "$fail" -ne 0 ]; then
  echo "MANUAL EXAMPLE COVERAGE FAILED"
  exit 1
fi
echo "MANUAL EXAMPLE COVERAGE HELD"
