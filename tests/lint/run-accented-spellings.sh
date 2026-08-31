#!/usr/bin/env bash
# run-accented-spellings.sh — one ASCII spelling of `resume' (issue #543)
#
# `docs/NAMING-CONVENTION.md', "One ASCII spelling for a word that has one",
# says an English word with an ordinary ASCII spelling is written that way even
# where a loanword accent would be defensible. Before #543 the tree carried the
# accented spelling of `resume' 225 times across 80 files while the class was
# named careerdossier-resume, the example was resume-english.tex, the target was
# `make resume', and the CI job was `resume'. Nothing stated which was right,
# which is why both survived -- including in the two strings that were typeset
# into the PDF /Title and the running page label of every document the toolkit
# produced.
#
# WHAT IT ASSERTS
#
# No tracked file spells `resume' with an accent. All four spellings are banned,
# precomposed and decomposed alike: the accent on the first `e', on the second,
# or on both.
#
# WHAT IT DOES NOT ASSERT
#
# Nothing about accented characters in general, and nothing about non-ASCII
# punctuation. This repository writes U+2014 1207 times, and its extraction and
# tagging fixtures deliberately carry `Zoe' with a diaeresis, `Dvorak' with a
# hacek and an acute, `Montreal', `Jose', `Lukasz' with a stroke, `Ipek' with a
# dotted capital, and `Angstrom' with a ring. Those are the subject under test,
# not spelling: tests/extraction/resume-decomposed-name.tex exists only to prove
# that decomposed input extracts as precomposed, and docs/ATS-EXTRACTION.md
# documents the rest as deliberate coverage. Removing those accents would delete
# the coverage rather than clean anything up. Control 2 below asserts that this
# lint cannot reach them.
#
# The ban is therefore over one word and not over a character class, and it
# needs no exception list, because no name or place this repository tests with
# contains the letters this searches for. An exception list is what let two
# spellings of one word coexist; a rule that permits the accented form in some
# position has to be read before it can be obeyed, and a contributor copying the
# nearest example never reads it.
#
# WHY THE PATTERN IS PCRE OVER BYTES
#
# Two constraints meet here.
#
# A runner that spelled the word the way it bans would match itself, and the
# assertion would fail on a correct tree -- the one failure mode that makes a
# guard worse than no guard, because the fix for it is to weaken the guard.
# Writing the pattern as PCRE byte escapes keeps this file pure ASCII, so it
# cannot match itself and the assertion covers the whole repository with no
# carve-out.
#
# And `git grep -F' cannot see the decomposed spellings at all. Measured on
# 2026-08-31 with git 2.50.1, against a file holding all four spellings: -F and
# -E each matched the three precomposed lines and missed both decomposed ones,
# under LC_ALL=C and en_US.UTF-8 alike. The blind spot is narrow and
# reproducible -- a literal containing `e' immediately followed by U+0301 never
# matches, while U+0301 alone, and `sum' alone, both match the same line. -P
# with byte escapes matches all four. Codepoint escapes (`\x{0301}') do not,
# which confirms the -P engine is running over bytes rather than in UTF-8 mode.
#
# So -P is load-bearing rather than stylistic. If a git without PCRE ever runs
# this, Control 1 fails and says so; it does not report a clean tree.
#
# THE CONTROL
#
# A guard that reports "no hits" is indistinguishable from a guard that never
# ran; #333 and #332 both shipped bounds no fixture reached. Control 1 writes
# each of the four spellings to a scratch file and runs the same search over it
# through the same function, so a pass reports that the search can still see
# what it is looking for. Both controls run `git grep --no-index' rather than a
# second tool: a control that exercises a different code path from the assertion
# stops covering it (#399).

set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../.." && pwd)"
fail=0

# U+00E9 as \xc3\xa9 and U+0301 as \xcc\x81, written as PCRE byte escapes so
# this file stays pure ASCII -- see "WHY THE PATTERN IS PCRE OVER BYTES" above.
# The fragments carry no leading `r', so one pattern covers both cases.
pattern='(?:\xc3\xa9|e\xcc\x81)sum|sum(?:\xc3\xa9|e\xcc\x81)'

# This file must not match its own pattern, or it would report itself and the
# fix for the failure would be to weaken the guard. Checked rather than asserted
# in prose, because an editor that helpfully precomposed an escape sequence
# would otherwise break the guard silently. Em dashes and the like are fine;
# only the banned byte sequences are not.
if git -C "$root" grep --no-index -q -P -e "$pattern" -- "$0" 2>/dev/null; then
  echo "FAIL: $(basename "$0") matches its own pattern."
  echo "      Write the accented bytes as PCRE byte escapes so this file"
  echo "      cannot match itself."
  exit 1
fi

# scan <git-grep-arg>... -- the one search the assertion and both controls run.
scan() {
  git -C "$root" grep -n -P -e "$pattern" "$@"
}

echo "== ASSERTION: no tracked file spells 'resume' with an accent =="
hits="$(scan -- . || true)"
if [ -n "$hits" ]; then
  echo "$hits" | sed 's/^/  /'
  echo
  echo "  Each line above spells 'resume' with an accent. Write it in ASCII:"
  echo "    the resume class, a resume entry, Resume - <name>"
  echo '  See docs/NAMING-CONVENTION.md, "One ASCII spelling for a word that'
  echo '  has one".'
  fail=1
else
  echo "  none"
fi

scratch="$root/build/accented-spellings-selftest"
rm -rf "$scratch"
mkdir -p "$scratch"

echo
echo "== CONTROL 1: the search still finds every spelling it bans =="
# Planted with printf so the bytes stay out of every tracked file, this one
# included. One file per spelling, so a partial blind spot is reported as such
# rather than masked by whichever sibling still matches.
plant() {
  printf "a $1 b\\n" > "$scratch/positive-$2.txt"
  if git -C "$root" grep --no-index -q -P -e "$pattern" \
       -- "$scratch/positive-$2.txt" 2>/dev/null; then
    echo "  OK: $3 is matched."
  else
    echo "  FAIL: $3 is NOT matched, so the assertion above reports nothing"
    echo "        whether or not the tree is clean."
    fail=1
  fi
}
plant 'r\303\251sum\303\251'   both-pre    "both accents, precomposed"
plant 'r\303\251sume'          first-pre   "first accent, precomposed"
plant 'resum\303\251'          second-pre  "second accent, precomposed"
plant 're\314\201sume\314\201' both-comb   "both accents, decomposed"
plant 're\314\201sume'         first-comb  "first accent, decomposed"
plant 'resume\314\201'         second-comb "second accent, decomposed"

echo
echo "== CONTROL 2: the ban does not reach the fixtures' accented names =="
# The names in "WHAT IT DOES NOT ASSERT" are deliberate coverage. If a future
# widening of the pattern started matching them, this reports it here rather
# than as a fixture someone deletes to make the lint pass.
printf 'Zo\303\253 Dvo\305\231\303\241k Montr\303\251al Jos\303\251 \305\201ukasz \304\260pek \303\205ngstr\303\266m r\303\251view\n' \
  > "$scratch/names.txt"
if git -C "$root" grep --no-index -q -P -e "$pattern" \
     -- "$scratch/names.txt" 2>/dev/null; then
  echo "  FAIL: the pattern matches a deliberate fixture name. Narrow the"
  echo "        pattern; do not change the fixtures."
  fail=1
else
  echo "  OK: no deliberate accented name is caught."
fi

rm -rf "$scratch"

echo
if [ "$fail" -eq 0 ]; then
  echo "ACCENTED SPELLING LINT PASSED"
else
  echo "ACCENTED SPELLING LINT FAILED"
fi
exit "$fail"
