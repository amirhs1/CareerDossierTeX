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
# WHY THE SEARCH IS index() OVER BYTES AND NOT A REGEX
#
# Two constraints meet here, and between them they rule out every regex engine
# on the path.
#
# A runner that spelled the word the way it bans would match itself, and the
# assertion would fail on a correct tree -- the one failure mode that makes a
# guard worse than no guard, because the fix for it is to weaken the guard. So
# the four byte sequences are built by `printf' from octal escapes and never
# appear literally in this file, which stays pure ASCII.
#
# And the obvious searches are each blind to part of what is banned. Measured
# 2026-08-31, against a file holding all four spellings:
#
#   git grep -F   matched the 3 precomposed, missed both decomposed
#   git grep -E   the same
#   git grep -P   matched all 4 on git 2.50.1 (macOS), matched NONE on
#                 git 2.55.0 (ubuntu-latest, CI)
#
# The -F and -E blind spot is narrow and reproducible: a literal holding `e'
# immediately followed by U+0301 never matches, while U+0301 alone, and `sum'
# alone, both match the same line. The -P result is worse than a blind spot,
# because it is platform-dependent -- byte escapes match raw bytes only where
# PCRE is not in UTF mode, and the first push of #543 went green locally and
# failed on CI with every planted spelling unmatched.
#
# index() is a byte-wise substring search: no pattern language, no engine, and
# nothing for a locale or a build option to reinterpret. It is run from perl
# rather than awk deliberately. Local awk is the one-true-awk and CI's is gawk
# or mawk (`CONTRIBUTING.md'), so an awk spelling of this could only be proven
# on one of the two toolchains from here -- and the -P row above is what an
# untested second toolchain costs. Perl has one implementation, is already a
# dependency of this harness (tests/tagging/structure-text.pl), and its byte
# semantics under LC_ALL=C with no encoding layer are unambiguous.
#
# The needles arrive through the environment rather than as arguments so that no
# quoting or escape-expansion layer sits between the printf that builds them and
# the index() that uses them.
#
# THE CONTROL
#
# A guard that reports "no hits" is indistinguishable from a guard that never
# ran; #333 and #332 both shipped bounds no fixture reached, and the CI failure
# above is the same shape caught in flight. Control 1 writes each of the six
# spellings to its own scratch file and runs the same search over it through the
# same function, so a pass reports that the search can still see what it is
# looking for on the toolchain actually executing it.

set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../.." && pwd)"
fail=0

# The four byte sequences, as octal escapes so they never appear literally in
# this file -- see "WHY THE SEARCH IS awk index()" above. U+00E9 is \303\251 and
# U+0301 is \314\201. None carries a leading `r', so one set covers both cases,
# and none is a substring of any accented name the fixtures use.
P1="$(printf '\303\251sum')"    # precomposed accent on the first e
P2="$(printf '\314\201sum')"    # decomposed accent on the first e
P3="$(printf 'sum\303\251')"    # precomposed accent on the second e
P4="$(printf 'sume\314\201')"   # decomposed accent on the second e
export P1 P2 P3 P4

# A self-check on the construction. `printf' is the one moving part between the
# code points and the search, and a build whose printf did not emit the bytes
# would hand every search below a wrong needle and report a clean tree. Length
# is in bytes, so LC_ALL=C.
check_len() { # <name> <needle> <expected bytes>
  local got
  got="$(LC_ALL=C printf '%s' "$2" | wc -c | tr -d ' ')"
  if [ "$got" != "$3" ]; then
    echo "FAIL: needle $1 is $got bytes, expected $3."
    echo "      Every search below would be over the wrong pattern."
    exit 1
  fi
}
check_len P1 "$P1" 5
check_len P2 "$P2" 5
check_len P3 "$P3" 5
check_len P4 "$P4" 6

# scan -- reads NUL-separated paths on stdin, prints `path:line: text' for every
# line holding any of the four needles. The one search the assertion and both
# controls run, so a control cannot drift onto a different code path (#399).
scan() {
  LC_ALL=C perl -0 -ne '
    my $f = $_;
    chomp $f;
    next unless -f $f;
    open(my $fh, "<", $f) or next;
    binmode $fh;
    {
      # -0 set the record separator to NUL for the path list on stdin; the file
      # being scanned is still read by lines.
      local $/ = "\n";
      while (my $l = <$fh>) {
        next unless index($l, $ENV{P1}) >= 0 || index($l, $ENV{P2}) >= 0
                 || index($l, $ENV{P3}) >= 0 || index($l, $ENV{P4}) >= 0;
        $l =~ s/\n\z//;
        print "$f:$.: $l\n";
      }
    }
    close $fh;
  '
}

# This file must not match its own needles, or it would report itself and the
# fix for the failure would be to weaken the guard. Checked rather than asserted
# in prose, because an editor that helpfully precomposed an escape sequence
# would otherwise break the guard silently. Em dashes and the like are fine;
# only the banned byte sequences are not.
if [ -n "$(printf '%s\0' "$0" | scan)" ]; then
  echo "FAIL: $(basename "$0") matches its own needles."
  echo "      Build them from octal escapes so this file stays ASCII."
  exit 1
fi

echo "== ASSERTION: no tracked file spells 'resume' with an accent =="
hits="$(git -C "$root" ls-files -z | scan)"
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
# rather than masked by whichever sibling still matches -- which is exactly how
# the platform-dependent -P result was caught.
plant() { # <octal-escaped spelling> <slug> <description>
  printf "a $1 b\\n" > "$scratch/$2.txt"
  if [ -n "$(printf '%s\0' "$scratch/$2.txt" | scan)" ]; then
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
# widening of the needles started matching them, this reports it here rather
# than as a fixture someone deletes to make the lint pass.
printf 'Zo\303\253 Dvo\305\231\303\241k Montr\303\251al Jos\303\251 \305\201ukasz \304\260pek \303\205ngstr\303\266m r\303\251view\n' \
  > "$scratch/names.txt"
if [ -n "$(printf '%s\0' "$scratch/names.txt" | scan)" ]; then
  echo "  FAIL: a needle matches a deliberate fixture name. Narrow the needle;"
  echo "        do not change the fixtures."
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
