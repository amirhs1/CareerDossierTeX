#!/usr/bin/env bash
# run-ctan-config.sh — the CTAN packaging configuration in build.lua (#264)
#
# A driver, not a checker. The assertions live in tests/lint/ctan-config.lua,
# because the value that matters most -- the version `l3build ctan' would
# publish -- is derived when build.lua is loaded and is not present in its text.
# That file's header says what is asserted and why; this one only finds an
# interpreter, runs it from the repository root, and turns a missing interpreter
# into a failure rather than a silent pass.
#
# `texlua' is the interpreter. It ships with the same TeX Live that `l3build'
# needs, so a tree that can run `make regression' can run this. If it is absent
# the lint FAILS: a check that could not be performed is not a check that
# passed, which is the #398 rule this repository applies everywhere else.
#
# Run from anywhere.
set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../.." && pwd)"

if ! command -v texlua >/dev/null 2>&1; then
  echo "== CTAN packaging configuration (build.lua) =="
  echo "  texlua NOT FOUND"
  echo "    -> this lint loads build.lua to read the version l3build would"
  echo "       publish, which no grep can see; install TeX Live (the same one"
  echo "       l3build needs) or run this on a machine that has it."
  echo
  echo "CTAN CONFIGURATION LINT FAILED"
  exit 1
fi

# ctan-config.lua resolves build.lua's own relative paths against the directory
# it is given, and build.lua reads careerdossier-base.sty relative to the
# working directory, so both have to be the repository root.
cd "$root" || exit 1
texlua tests/lint/ctan-config.lua "$root"
