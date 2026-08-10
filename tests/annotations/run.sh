#!/usr/bin/env bash
# run.sh — the action type of every link annotation the toolkit emits
# (issue #328).
#
# The other link-facing suites all read the *text* layer: `links' decides
# copy-paste integrity from word bounding boxes, `extraction' and `tagging'
# compare extracted strings. None of them can see what a link annotation
# actually does, and #328 was exactly that kind of defect — the page, the
# extracted text, and the copy-paste invariant were all correct while every
# scheme-less profile link was emitted as a GoToR action pointing at a remote
# PDF that does not exist. This suite is the missing assertion.
#
# WHY THE ACTION TYPE CAN BE WRONG SILENTLY. hyperref decides what an \href
# target is by splitting it on a catcode-12 colon (\@hyper@readexternallink).
# A colon written literally inside \ExplSyntaxOn is a letter, catcode 11, so a
# scheme the package supplies itself is invisible to that split: hyperref
# concludes the target is a local file, appends `.pdf', and emits GoToR. No
# warning, no error, nothing in the log. A value the *document* writes out in
# full is unaffected, because that colon is read from the user's file at
# catcode 12 — which is why a fixture has to compare the two spellings against
# each other rather than merely check that a link exists.
#
# WHAT EACH FIXTURE DECLARES. One directive per link the document renders, in
# any order:
#
#   % URIEXPECT: https://example.org/ada
#
# The runner collects the URI actions the PDF carries and requires the two
# multisets to match exactly. Exact, not "contains": an extra annotation is as
# much a defect as a missing one, and a GoToR left behind by a half-fix would
# otherwise pass unnoticed by a subset check.
#
# It additionally fails any fixture whose PDF carries a GoToR action at all.
# That is the redundant half of the assertion and it is deliberate: it names
# the actual #328 symptom in the failure output, so a future regression reads
# as "a GoToR came back" rather than as an opaque multiset difference.
#
# READING THE PDF. Do not reach for `strings | grep' on a default build: link
# annotations live in a compressed object stream, and a text search finds
# nothing whether or not the annotation is there — a false negative that reads
# exactly like a pass. Every fixture therefore \input's uncompressed.inc, and
# every assertion is paired with a positive control (`/Subtype /Link' must be
# found by the same method on the same file) so a build that emitted no links
# at all cannot pass by silence.
#
# Requirements: lualatex. Run from anywhere.
set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../.." && pwd)"
work="${TMPDIR:-/tmp}/careerdossier-annotations-$$"
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

# Pull the URI targets out of the emitted annotations.
#
# A URI action is written /S/URI/URI(<address>) — possibly with /Type/Action
# ahead of it and possibly split across lines by the PDF writer, so the file is
# flattened onto one line before matching. The addresses these fixtures use
# contain no parentheses and no backslashes, so the naive `[^)]*' body is
# exact here; a fixture that needed one would have to teach this function
# about PDF string escaping first.
uri_targets() {
  tr '\n\r' '  ' < "$1" \
    | grep -oa '/S */URI */URI *([^)]*)' \
    | sed -e 's|.*/URI *(||' -e 's|)$||'
}

check_actions() {
  local job="$1" source="$2"
  local pdf="$work/$job.pdf"
  local expected="$work/$job.expected" found="$work/$job.found"

  # Positive control: the fixture must have rendered links at all. Without it a
  # document that silently stopped emitting annotations — a broken \href, a
  # missing hyperref — would match an empty found-set against a mistakenly
  # empty expected-set, or fail with a message pointing at the wrong thing.
  if ! grep -qa '/Subtype */Link' "$pdf"; then
    record_failure "$job: no link annotation in the PDF, so its action check proves nothing"
    return
  fi

  if grep -qa '/S */GoToR' "$pdf"; then
    record_failure "$job: a link is emitted as a GoToR (remote-PDF) action, not a URI action"
    tr '\n\r' '  ' < "$pdf" | grep -oa '/F *([^)]*) */S */GoToR' | sed 's/^/    /'
  fi

  sed -n 's/^% URIEXPECT:[[:space:]]*//p' "$here/$source" | LC_ALL=C sort > "$expected"
  if [ ! -s "$expected" ]; then
    record_failure "$job: no % URIEXPECT: directives — the fixture asserts nothing"
    return
  fi
  uri_targets "$pdf" | LC_ALL=C sort > "$found"

  if diff -u "$expected" "$found" > "$work/$job.diff"; then
    echo "  $job: $(wc -l < "$found" | tr -d ' ') URI actions, all as declared"
  else
    record_failure "$job: emitted URI actions differ from the declared set"
    sed -e '1,2d' -e 's/^/    /' "$work/$job.diff"
    echo "    (-- expected but absent, ++ present but not declared)"
  fi
}

echo "== every link the toolkit emits is a URI action =="
for source in "$here"/*.tex; do
  base="$(basename "$source" .tex)"
  if compile_fixture "$base.tex" "$base"; then
    check_actions "$base" "$base.tex"
  fi
done
echo

if [ "$fail" -eq 0 ]; then
  echo "ALL ANNOTATION FIXTURES PASSED"
else
  echo "ANNOTATION FIXTURES FAILED"
fi
exit "$fail"
