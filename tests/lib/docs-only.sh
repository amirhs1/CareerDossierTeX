#!/usr/bin/env bash
# docs-only.sh — is a change docs-only? The one copy of the path list (#603)
#
# A docs-only change touches nothing but documentation and agent tooling, so no
# TeX suite can fail on it. Two callers act on that:
#
#   - the `changes` job in .github/workflows/build.yml skips CI's TeX jobs on a
#     docs-only pull request (#568), over the pull request's diff;
#   - `make check` dispatches only the lint targets on a docs-only working
#     tree (tests/check-parallel.sh), unless FULL=1.
#
# Both call this script, so the list below is the only one and the two cannot
# drift apart. CONTRIBUTING.md, "CI expectations", is where the rule is
# documented.
#
# USAGE
#
#   tests/lib/docs-only.sh --paths
#       Classify the newline-separated paths on standard input.
#   tests/lib/docs-only.sh --worktree [<base-ref>]
#       Classify the working tree of the repository in the current directory
#       against its merge base with <base-ref>, default origin/main: committed,
#       staged, and unstaged changes, and untracked files that are not ignored.
#       The paths go to standard output, one per line.
#
# EXIT STATUS
#
#   0  docs-only: at least one path, and every path on the list below
#   1  not docs-only, including an empty change; standard error names why
#   2  could not classify: an unknown option, no <base-ref>, not a git
#      checkout, or a git error; standard error names which
#
# Callers run every suite on anything but 0, so a failure here can only make a
# run larger. An empty change counts as not docs-only for the same reason: a
# gate that has nothing to compare against runs everything.
#
# THE LIST
#
# It is safe only while no TeX job and no TeX-running target reads a path on
# it. Re-run these before widening it, and whenever a runner starts reading
# documentation; every hit must be a comment, a message, or `tests/lint/`,
# which `lint` runs on every change:
#
#   git grep -nE '\.md' -- build.lua Makefile tests ':!tests/lint'
#   git grep -nE '\.claude|\.codex|githooks|gitmessage' -- build.lua Makefile tests ':!tests/lint'
#
# `doc/careerdossier.tex` is not on the list: the `manual` job builds it. This
# script is not on it either, so a change to it runs everything.
#
# Renames are listed as both sides (--no-renames), so moving a source file into
# docs/ still counts as touching the file it removes. A path git prints quoted,
# because it holds an unusual character, matches nothing here and so counts as
# not docs-only, which is the safe direction.
#
# Written for macOS /bin/bash 3.2 as well as modern bash.

set -uo pipefail

docs='^(docs/|\.agents/|\.github/ISSUE_TEMPLATE/|\.claude/|\.codex/|\.githooks/|\.gitmessage$|.*\.md$)'

unclassified() {
  printf 'docs-only: cannot classify: %s\n' "$*" >&2
  exit 2
}

# Reads paths on standard input; returns 0, or 1 with the reason on stderr.
classify_paths() {
  local line count=0
  while IFS= read -r line || [ -n "$line" ]; do
    [ -n "$line" ] || continue
    count=$((count + 1))
    if ! [[ "$line" =~ $docs ]]; then
      printf 'docs-only: not docs-only: %s\n' "$line" >&2
      return 1
    fi
  done
  if [ "$count" -eq 0 ]; then
    printf 'docs-only: not docs-only: the change is empty\n' >&2
    return 1
  fi
  return 0
}

classify_worktree() {
  local base_ref="$1" base changed untracked top all
  top="$(git rev-parse --show-toplevel 2>/dev/null)" \
    || unclassified "not a git checkout"
  # `git ls-files` prints paths relative to the current directory and
  # `git diff --name-only` relative to the top level; from the top they agree.
  cd "$top" || unclassified "cannot enter $top"
  git rev-parse --verify --quiet "$base_ref^{commit}" > /dev/null 2>&1 \
    || unclassified "no $base_ref to compare against"
  base="$(git merge-base "$base_ref" HEAD 2>/dev/null)" \
    || unclassified "no merge base between $base_ref and HEAD"
  # Against a commit, `git diff` compares the working tree, so one command
  # covers what is committed since the merge base, staged, and unstaged.
  changed="$(git diff --no-renames --name-only "$base" 2>/dev/null)" \
    || unclassified "git diff against $base failed"
  untracked="$(git ls-files --others --exclude-standard 2>/dev/null)" \
    || unclassified "git ls-files failed"
  all="$(printf '%s\n%s\n' "$changed" "$untracked" | sed '/^$/d' | sort -u)"
  [ -n "$all" ] && printf '%s\n' "$all"
  printf '%s\n' "$all" | classify_paths
}

case "${1:-}" in
  --paths)
    [ "$#" -eq 1 ] || unclassified "--paths takes no argument"
    classify_paths
    exit "$?"
    ;;
  --worktree)
    [ "$#" -le 2 ] || unclassified "--worktree takes at most one base ref"
    classify_worktree "${2:-origin/main}"
    exit "$?"
    ;;
  *)
    unclassified "unknown option: ${1:-(none)}; use --paths or --worktree"
    ;;
esac
