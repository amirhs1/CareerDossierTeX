#!/usr/bin/env bash
# run-docs-only.sh — the docs-only classifier's verdicts (#603)
#
# tests/lib/docs-only.sh decides whether a change touches only documentation
# and agent tooling. Two callers act on its answer: the `changes` job in
# .github/workflows/build.yml, which skips CI's TeX jobs on such a pull request
# (#568), and `make check`, which then runs only the lint targets. A classifier
# that called a source change docs-only would let both of them pass a change no
# TeX suite had read, so the claims pinned here are the ones that would be false
# if it did:
#
#   1. Over a path list (`--paths`), each tests/lint/fixtures/docsonlyfixture-*
#      list gets the verdict the table in tests/lint/fixtures/README.md gives
#      it. The expected verdicts come from the documented path list in
#      CONTRIBUTING.md, "CI expectations", not from running the classifier.
#      `-sty`, `-manual`, `-makefile`, `-workflow`, `-rename`, and `-classifier`
#      are the planted violations: a list that is docs-only but for one path.
#   2. Over a working tree (`--worktree`), in a throwaway repository: a
#      committed, a staged, an unstaged, and an untracked change each count, a
#      staged rename of a `.sty` into docs/ counts as touching the `.sty`, and
#      an empty diff is not docs-only. The expected verdicts follow from the
#      same documented list.
#   3. When it cannot classify — no `origin/main`, not a git checkout, or an
#      unknown option — it says so with exit status 2, which both callers turn
#      into a full run. Only 0, 1, and 2 are verdicts: any other status fails
#      this lint rather than counting as a match.
#
# It needs bash and git, and no TeX, so it runs on the TeX-free CI lint runner.
# The throwaway repository is built under build/, which is gitignored, with the
# user's and the system's git configuration switched off, so a global excludes
# file or hook cannot change what it sees.
#
# Run from anywhere.
set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../.." && pwd)"
classifier="$root/tests/lib/docs-only.sh"
fixtures="$here/fixtures"
scratch="$root/build/lint-docs-only"
fail=0

echo "== the docs-only classifier's verdicts =="

if [ ! -x "$classifier" ]; then
  echo "  FAIL: $classifier is missing or not executable"
  echo
  echo "DOCS-ONLY CLASSIFIER LINT FAILED"
  exit 1
fi

verdict_name() {
  case "$1" in
    0) printf 'docs-only' ;;
    1) printf 'full' ;;
    2) printf 'unclassified' ;;
    *) printf 'exit %s' "$1" ;;
  esac
}

# report <label> <want> <status>
report() {
  local label="$1" want="$2" got
  got="$(verdict_name "$3")"
  case "$3" in
    0|1|2) ;;
    *)
      echo "  FAIL: $label: the classifier exited $3, which is not a verdict"
      fail=1
      return
      ;;
  esac
  if [ "$got" = "$want" ]; then
    echo "  ok: $label -> $want"
  else
    echo "  FAIL: $label -> $got; it should be $want"
    fail=1
  fi
}

# --- 1. Path lists ----------------------------------------------------------

# expect_paths <fixture> <docs-only|full>
expect_paths() {
  local name="$1" want="$2" file="$fixtures/$1"
  if [ ! -f "$file" ]; then
    echo "  FAIL: fixture $name is missing"
    fail=1
    return
  fi
  "$classifier" --paths < "$file" > /dev/null 2>&1
  report "$name" "$want" "$?"
}

echo "-- over a path list (--paths)"
expect_paths docsonlyfixture-docs.txt docs-only
expect_paths docsonlyfixture-sty.txt full
expect_paths docsonlyfixture-manual.txt full
expect_paths docsonlyfixture-makefile.txt full
expect_paths docsonlyfixture-workflow.txt full
expect_paths docsonlyfixture-rename.txt full
expect_paths docsonlyfixture-classifier.txt full
expect_paths docsonlyfixture-empty.txt full

"$classifier" --no-such-option < /dev/null > /dev/null 2>&1
report "an unknown option" unclassified "$?"

# --- 2 and 3. A working tree ------------------------------------------------

echo "-- over a working tree (--worktree)"

rm -rf "$scratch"
repo="$scratch/repo"
mkdir -p "$repo" "$scratch/not-a-repo"

# Isolated from every git configuration but the one given here.
g() {
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1 \
    git -C "$repo" -c user.name=lint -c user.email=lint@invalid \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null "$@"
}

# worktree <label> <want> [<expected path in the listing>]
worktree() {
  local label="$1" want="$2" path="${3:-}" out="$scratch/listing.txt" status
  ( cd "$repo" && GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1 \
      "$classifier" --worktree ) > "$out" 2> "$scratch/stderr.txt"
  status="$?"
  report "$label" "$want" "$status"
  if [ -n "$path" ] && ! grep -Fx -- "$path" "$out" > /dev/null 2>&1; then
    echo "  FAIL: $label: the listing does not name $path"
    sed 's/^/        /' "$out"
    fail=1
  fi
}

# The git directory lives beside the work tree, which holds only a `.git`
# gitfile pointing at it. Classification sees an ordinary checkout, and nothing
# is written under a directory named `.git`, which restricted sandboxes deny;
# `--template=` copies no sample hooks for the same reason.
setup_failed() {
  echo "  FAIL: could not $1 in the throwaway repository; see $scratch/setup.log"
  echo
  echo "DOCS-ONLY CLASSIFIER LINT FAILED"
  exit 1
}

if ! { g init -q --template= --separate-git-dir="$scratch/gitdir" "$repo" \
       && mkdir -p "$repo/docs" \
       && printf 'base\n' > "$repo/docs/a.md" \
       && printf 'base\n' > "$repo/careerdossier-x.sty" \
       && printf 'all:\n' > "$repo/Makefile" \
       && g add -A && g commit -q -m base \
       && g update-ref refs/remotes/origin/main HEAD \
       && g checkout -q -b work; } > "$scratch/setup.log" 2>&1; then
  setup_failed "build the base commit"
fi

worktree "no change since origin/main" full

printf 'edit\n' >> "$repo/docs/a.md"
g commit -q -am 'docs edit' >> "$scratch/setup.log" 2>&1 \
  && g diff --quiet HEAD || setup_failed "commit the docs edit"
worktree "a committed docs edit" docs-only docs/a.md

printf 'edit\n' >> "$repo/Makefile"
g add Makefile >> "$scratch/setup.log" 2>&1 || setup_failed "stage Makefile"
worktree "a staged Makefile edit" full Makefile
g reset -q --hard >> "$scratch/setup.log" 2>&1 || setup_failed "reset"

printf 'edit\n' >> "$repo/careerdossier-x.sty"
worktree "an unstaged .sty edit" full careerdossier-x.sty
g checkout -q -- careerdossier-x.sty >> "$scratch/setup.log" 2>&1 \
  || setup_failed "restore careerdossier-x.sty"

printf 'new\n' > "$repo/careerdossier-y.sty"
worktree "an untracked .sty" full careerdossier-y.sty
rm -f "$repo/careerdossier-y.sty"

# Without --no-renames, git would list only the new path, under docs/, and the
# move would read as docs-only.
g mv careerdossier-x.sty docs/careerdossier-x.sty >> "$scratch/setup.log" 2>&1 \
  || setup_failed "move careerdossier-x.sty into docs/"
worktree "a staged rename of a .sty into docs/" full careerdossier-x.sty
g reset -q --hard >> "$scratch/setup.log" 2>&1 || setup_failed "reset"

worktree "the docs edit again, tree restored" docs-only docs/a.md

g update-ref -d refs/remotes/origin/main >> "$scratch/setup.log" 2>&1 \
  || setup_failed "delete origin/main"
worktree "no origin/main" unclassified

# GIT_CEILING_DIRECTORIES stops git's search for a repository before it reaches
# this checkout, which encloses build/.
( cd "$scratch/not-a-repo" && GIT_CEILING_DIRECTORIES="$scratch" \
    "$classifier" --worktree ) > /dev/null 2>&1
report "not a git checkout" unclassified "$?"

echo
if [ "$fail" -eq 0 ]; then
  echo "DOCS-ONLY CLASSIFIER LINT PASSED"
else
  echo "DOCS-ONLY CLASSIFIER LINT FAILED"
fi
exit "$fail"
