#!/usr/bin/env bash
# run.sh -- PDF metadata on the DEFAULT (untagged) build path.
#
# Issue #276. Every other suite that sees a /Lang sees one the kernel put there:
# all thirteen fixtures that produce one pass \DocumentMetadata{lang=en}, and
# \DocumentMetadata is what writes the catalog entry in that case. The package's
# own contribution -- the derived `pdflang' in careerdossier-components -- is
# therefore invisible to the existing suites, and so is anything that breaks it.
# This suite exists to look at the path a user actually takes when they do not
# opt into tagging.
#
# What it asserts:
#
#   * every class emits a catalog /Lang on the default path;
#   * a document's own \hypersetup{pdflang=...} reaches the PDF unchanged --
#     including the en-GB form docs/API.md advertises;
#   * /Lang survives careerdossier-components being loaded AFTER hyperref.
#
# The third is the one with teeth. Without \DocumentMetadata the kernel's PDF
# management is inactive, so hyperref writes the catalog from its own
# `begindocument' chunk (/Lang(\@pdflang) in hluatex.def). A pdflang set after
# that chunk runs is simply not in the file, and nothing is logged. The four
# classes load this package before hyperref, so their chunk happens to come
# first; a document that loads the package directly, after hyperref, does not
# get that for free. careerdossier-components declares a \DeclareHookRule to
# state the requirement, and this is the fixture that fails without it. /Title
# and /Author cannot fail this way -- they go to the Info dictionary at
# \end{document} -- which is why this suite is about /Lang specifically.
#
# READING THE CATALOG. Do not reach for `strings | grep' here. On the default
# path nothing sets compresslevel, so the catalog is inside a compressed object
# stream and a text search of the file finds nothing whether or not /Lang is
# present -- a false negative that reads exactly like the bug. (That is how
# #276 came to be reported against behaviour that was in fact working: the
# tagging fixtures set compresslevel=0 and were visible, the default-path builds
# were not.) These fixtures therefore turn compression off explicitly, and every
# assertion is paired with a positive control so a build that produced nothing
# cannot pass by silence.
#
# Requirements: lualatex. Run from anywhere.
set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../.." && pwd)"
work="${TMPDIR:-/tmp}/careerdossier-metadata-$$"
trap 'rm -rf "$work"' EXIT
mkdir -p "$work"

export TEXINPUTS="$here:$root:${TEXINPUTS:-}"
fail=0

if ! command -v lualatex >/dev/null 2>&1; then
  echo "MISSING required command: lualatex"
  exit 1
fi

record_failure() {
  echo "  FAIL: $1"
  fail=1
}

compile_fixture() {
  local source="$1" job="$2"
  if ! lualatex -output-directory="$work" -jobname="$job" \
      -halt-on-error -interaction=nonstopmode "$here/$source" \
      >"$work/$job.stdout" 2>&1; then
    # The work directory is temporary and is gone by the time anyone reads a CI
    # log, so the transcript has to be in the log itself.
    record_failure "$source did not compile"
    tail -20 "$work/$job.stdout" | sed 's/^/    /'
    return 1
  fi
}

# Assert the catalog's /Lang, and prove the reading method works on this file.
#
# The positive control is not ceremony. Both halves of this check are searches
# for a string in a PDF, and a search that finds nothing looks the same whether
# the entry is absent, the build failed, or the file is compressed. Requiring
# /Type /Catalog to be found by the same method on the same file rules out the
# last two.
check_lang() {
  local job="$1" expected="$2"
  local pdf="$work/$job.pdf" found

  if ! grep -qa '/Type */Catalog' "$pdf"; then
    record_failure "$job: cannot read the catalog, so its /Lang check proves nothing"
    return
  fi

  found="$(grep -oa '/Lang *([A-Za-z-]*)' "$pdf" | head -1 | tr -d ' ')"
  if [ -z "$found" ]; then
    record_failure "$job has no catalog /Lang"
  elif [ "$found" != "/Lang($expected)" ]; then
    record_failure "$job has $found, expected /Lang($expected)"
  else
    echo "  $job: $found"
  fi
}

echo "== default path: every class emits /Lang =="
for base in resume letter cv statement; do
  if compile_fixture "$base-default.tex" "$base-default"; then
    check_lang "$base-default" en
  fi
done
echo

echo "== a document's own pdflang is what reaches the PDF =="
if compile_fixture resume-user-lang.tex resume-user-lang; then
  check_lang resume-user-lang en-GB
fi
echo

echo "== /Lang survives the package being loaded after hyperref =="
if compile_fixture components-after-hyperref.tex components-after-hyperref; then
  check_lang components-after-hyperref en
fi
echo

if [ "$fail" -eq 0 ]; then
  echo "ALL METADATA FIXTURES PASSED"
else
  echo "METADATA FIXTURES FAILED"
fi
exit "$fail"
