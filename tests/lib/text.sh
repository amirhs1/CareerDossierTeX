#!/usr/bin/env bash
# text.sh — extracted-text guards that distinguish three states, not two.
#
# WHAT THIS IS
#
# A library, sourced rather than executed. Every runner that asserts something
# about a PDF's extracted text asks two questions of it: capture the text, then
# ask whether a string is in it. This file owns both, because the two-state
# spelling of the second question is issue #398.
#
# THE DEFECT IT REPLACES
#
# The shape was
#
#   if ! printf '%s\n' "$page_text" | grep -Fq "$needle"; then
#     echo "  MISSING RUNNING HEADER on page $n: $needle"
#
# and under `make check JOBS=8` it reported a label MISSING that was on line 1
# of a page `pdftotext` had extracted correctly, exited 0 on, and that the
# runner's own re-extraction found. A pipeline that returns non-zero for any
# reason other than "no match" is indistinguishable from absent text.
#
# The observed symptom is a hollow failure. Twelve lines above each of those
# sites the same test is inverted --
#
#   if printf '%s\n' "$page_text" | grep -Fq "$needle"; then
#     echo "  UNEXPECTED SCREEN RUNNING HEADER on page $n"
#
# -- and whatever makes the pipeline spuriously non-zero makes *that* branch
# spuriously false, so a real violation is not reported and the fixture passes.
# That is the half that matters. This repository's characteristic failure is a
# run that reports green without having done the work, and a guard with two
# states is one more way to produce one.
#
# WHY THE MECHANISM IS NOT NAMED HERE
#
# #398 tested three candidate mechanisms -- a `grep -q` SIGPIPE race under
# `pipefail`, `pdftotext` failing under concurrency, and the pipeline failing
# under fork pressure -- and *none* reproduced in isolation, across 2000, 640,
# and 7200 trials respectively. So the fix is not a repair of a diagnosed cause.
# It removes the class:
#
#   1. The match runs in the shell. `case` with a quoted expansion matches the
#      needle literally -- the same semantics as `grep -F` -- and forks nothing,
#      opens no pipe, and runs no external program. There is no longer a channel
#      by which a match can be reported as a miss, whatever the load.
#   2. What genuinely cannot be answered says so. When the extraction itself
#      could not be performed, the text is the CDTEXT_UNAVAILABLE sentinel, and
#      every predicate below returns 2 rather than 0 or 1. A caller that ignores
#      the difference gets a failure, not a verdict.
#
# The regex predicate still needs grep, since `case` cannot express an ERE. It
# uses a here-string rather than a pipe -- the form tests/links/run.sh and
# tests/bibliography/run.sh already carry for this reason -- and reads grep's
# status three ways: 0 found, 1 absent, anything else could not be checked.
#
# THE CONTRACT
#
#   0  present   the needle occurs in the text
#   1  absent    it does not
#   2  unknown   the question could not be answered, and no verdict is available
#
# A caller MUST treat 2 as a failure of its own, naming that the check could not
# run. Callers here do that through a per-runner wrapper, because what a runner
# does with a failure -- print and set a flag, or push onto a `failed` array --
# differs per runner and only the predicate is shared.
#
# WHERE IT RUNS
#
# macOS /bin/bash 3.2 as well as modern bash. No arrays, no namerefs, no process
# substitution.
#
# The committed negative controls live in tests/lint/run-text-guards.sh, which
# drives these functions over synthetic text, compiles nothing, and runs in the
# sub-second `lint` slot alongside the fan-out controls.

# The value a capture takes when the extraction could not be performed. It is
# not text that any document could contain, and it is what makes "could not be
# checked" survive assignment into an ordinary shell variable -- which is the
# only channel a `$(...)` capture has.
CDTEXT_UNAVAILABLE='@@cdossier:text-unavailable@@'

# text_is_unavailable <text>
#
# 0 when the capture failed. Callers rarely need this: the predicates below
# already answer 2 for such a text, and a caller that handles 2 handles this.
text_is_unavailable() {
  case "$1" in
    *"$CDTEXT_UNAVAILABLE"*) return 0 ;;
    *) return 1 ;;
  esac
}

# text_contains <text> <needle>
#
# Substring match, `grep -F` semantics: the needle is matched literally, so a
# needle containing *, ?, [ or \ is not a pattern. That literalness is what the
# quoting in the `case` patterns below buys, and removing it would silently turn
# `ORCID: 0000-0002-1825-0097` into a glob.
#
# An empty needle is answered 2, not 0. `grep -Fq ""` matches every text, so a
# guard that reaches here with an unset label is asserting nothing while
# reporting a pass -- which is the same hollow pass this file exists to remove,
# arriving by a different road.
text_contains() {
  [ "$#" -eq 2 ] || return 2
  [ -n "$2" ] || return 2
  text_is_unavailable "$1" && return 2
  case "$1" in
    *"$2"*) return 0 ;;
    *) return 1 ;;
  esac
}

# text_contains_line <text> <line>
#
# Whole-line match, `grep -Fqx` semantics. The text is wrapped in newlines so
# that its first and last lines are reachable by the same pattern as the ones
# between them; a trailing newline in the text only ever adds an empty line,
# which no non-empty needle equals.
text_contains_line() {
  [ "$#" -eq 2 ] || return 2
  [ -n "$2" ] || return 2
  text_is_unavailable "$1" && return 2
  local nl='
'
  case "$nl$1$nl" in
    *"$nl$2$nl"*) return 0 ;;
    *) return 1 ;;
  esac
}

# text_matches <text> <ere>
#
# `grep -Eq` semantics, for the two assertions that are genuinely regular
# expressions rather than strings. The here-string is the point: with a pipe,
# grep's early exit under `-q` hands the producer a SIGPIPE and `pipefail`
# reports the resulting status as "no match". A here-string has no producer to
# signal.
#
# grep's status is read three ways rather than as a boolean. `grep` answers 1
# for "no match" and 2 or more for "I could not do this" -- an unreadable input,
# a bad expression, or, at 127, no grep at all -- and only the first of those is
# a verdict about the text.
text_matches() {
  [ "$#" -eq 2 ] || return 2
  [ -n "$2" ] || return 2
  text_is_unavailable "$1" && return 2
  local rc
  grep -Eq -- "$2" <<< "$1"
  rc="$?"
  [ "$rc" -le 1 ] && return "$rc"
  return 2
}

# text_count_lines <text> <needle>
#
# Prints the number of lines containing <needle>, `grep -Fc` semantics, and
# returns 0. Prints nothing and returns 2 when the count cannot be taken.
#
# A count needs the third state more than a predicate does, not less, because
# its unperformable answer is numerically indistinguishable from its commonest
# *passing* answer. `printf … | grep -Fc "$needle" || true` over text that was
# never extracted yields `0`, and every caller here compares against `0` or
# tests `-eq 1`; so a check that could not run reported a clean page. That is
# the hollow pass of #398 arriving as arithmetic instead of as a boolean, and
# `|| true` is what makes it silent — it turns any pipeline failure into an
# empty string, and `[ "" -ne 0 ]` errors to stderr and is read as false.
#
# The counterexample worth copying is tests/layout/run.sh's page-fill parse,
# which is safe without this: it compares the record count against the page
# count derived independently from the log, so "found nothing" cannot read as
# "nothing to find". Where an independent expected value exists, use it.
text_count_lines() {
  [ "$#" -eq 2 ] || return 2
  [ -n "$2" ] || return 2
  text_is_unavailable "$1" && return 2
  local count=0 line
  while IFS= read -r line; do
    case "$line" in
      *"$2"*) count=$((count + 1)) ;;
    esac
  done <<< "$1"
  printf '%s\n' "$count"
  return 0
}

# text_count_matches <text> <ere>
#
# text_count_lines for the counts whose subject is a regular expression rather
# than a string. Same contract: prints the count and returns 0, or prints
# nothing and returns 2.
#
# `grep -c` answers 1 when the count is 0, which is a verdict about the text and
# not an error, so only 2 and above mean the count could not be taken. That is
# precisely the distinction `|| true` erased.
text_count_matches() {
  [ "$#" -eq 2 ] || return 2
  [ -n "$2" ] || return 2
  text_is_unavailable "$1" && return 2
  local out rc
  out="$(grep -Ec -- "$2" <<< "$1")"
  rc="$?"
  [ "$rc" -le 1 ] || return 2
  case "$out" in
    ''|*[!0-9]*) return 2 ;;
  esac
  printf '%s\n' "$out"
  return 0
}

# text_extract <pdf> [pdftotext option...]
#
# The capture half. Prints the PDF's extracted text with form feeds removed, or
# CDTEXT_UNAVAILABLE when the extraction could not be performed -- no pdftotext,
# no such file, or a non-zero exit.
#
# It always exits 0. That is deliberate: the caller's `$(...)` would discard a
# non-zero status anyway, and a capture that failed *silently into a variable*
# is the state that reads as "the page is empty". Unavailability travels in the
# value instead, where the predicates above can see it.
#
# Form feeds are stripped in the shell rather than through `| sed '/^\f/d'` or
# `| tr -d '\f'`, which is one fewer pipeline between the extraction and the
# assertion. The two spellings differed only in whether an empty line was left
# behind, and no non-empty needle matches an empty line under either predicate.
text_extract() {
  local pdf="$1"
  shift
  local out
  command -v pdftotext > /dev/null 2>&1 || {
    printf '%s\n' "$CDTEXT_UNAVAILABLE"
    return 0
  }
  [ -f "$pdf" ] || {
    printf '%s\n' "$CDTEXT_UNAVAILABLE"
    return 0
  }
  if ! out="$(pdftotext -enc UTF-8 "$@" "$pdf" - 2> /dev/null)"; then
    printf '%s\n' "$CDTEXT_UNAVAILABLE"
    return 0
  fi
  printf '%s\n' "${out//$'\f'/}"
  return 0
}

# text_page <pdf> <page> [pdftotext option...]
#
# text_extract narrowed to one page.
text_page() {
  local pdf="$1" page="$2"
  shift 2
  text_extract "$pdf" -f "$page" -l "$page" "$@"
}
