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
#   * so does a \DocumentMetadata{lang=...}, which is the other route in and the
#     one the module cannot see through hyperref;
#   * /Lang survives careerdossier-components being loaded AFTER hyperref;
#   * the derived /Title is the same string on the default and tagged paths.
#
# The last one is the exception to the "default path" framing, and is here
# because it has nowhere better to be: it is a question about the Info
# dictionary, which is this suite's subject, and it cannot be asked from one
# path alone. Issue #428, where the tagged path shipped `Cover Letter -- Name'
# against the default path's `Cover Letter – Name' from identical source.
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

echo "== a document's own language is what reaches the PDF =="
if compile_fixture resume-user-lang.tex resume-user-lang; then
  check_lang resume-user-lang en-GB
fi
# The other route in. \hypersetup lands in hyperref's \@pdflang, which the
# module reads; \DocumentMetadata{lang=...} does not, so a module reading only
# \@pdflang overwrites it with the derived `en' and says nothing. `de' is a
# language this project would never derive, so a pass here cannot come from the
# value happening to match.
if compile_fixture resume-documentmetadata-lang.tex resume-documentmetadata-lang; then
  check_lang resume-documentmetadata-lang de
fi
echo

echo "== /Lang survives the package being loaded after hyperref =="
if compile_fixture components-after-hyperref.tex components-after-hyperref; then
  check_lang components-after-hyperref en
fi
echo

echo "== the derived /Title is the same on both build paths =="
# Issue #428. Everything above this line is about the default path, because
# \DocumentMetadata writes those catalog entries itself and hides what the
# package contributes. /Title is the one field where the comparison is the
# subject: both paths carry it, they disagreed, and no suite could see it.
#
# The two writers serialise the same string differently -- hyperref's
# \pdfstringdef emits a literal PDF string with octal escapes, the kernel's PDF
# management emits a hex string -- so a byte comparison of the two files would
# report a difference that is only syntax. title_hex normalises both to the
# UTF-16BE code units they encode, which is the level at which "the same title"
# is a meaningful claim.
#
# The expected value is written out as hex rather than as text because that is
# what the assertion compares; in readable form it is
#
#   Cover Letter <U+2013 EN DASH> Metadata Fixture
#
# and it is built here from the string, not copied out of a build, so a fixture
# cannot pass by agreeing with whatever the package currently emits.
expected_title_hex="\
0043006F0076006500720020004C0065007400740065007200202013\
0020004D00650074006100640061007400610020004600690078007400750072\
0065"

# Read an Info dictionary string -- /Title or /Author -- as uppercase UTF-16BE
# hex, BOM removed.
#
# The pattern deliberately requires a string value -- `(' or `<'. A tagged file
# also carries /Title keys whose values are a name (in the role map) and an
# indirect reference (in the structure tree), and matching those would compare
# the wrong thing while looking like it worked. Exactly one string-valued
# instance of the key is expected, and info_hex fails rather than guessing if
# that is not what it finds.
info_hex() {
  local pdf="$1" key="$2" raw count
  count="$(grep -ac "/$key *[(<][^)>]*[)>]" "$pdf")"
  if [ "$count" != "1" ]; then
    return 1
  fi
  raw="$(grep -ao "/$key *[(<][^)>]*[)>]" "$pdf")"
  printf '%s\n' "$raw" | awk -v key="$key" '
    BEGIN { for (n = 32; n < 127; n++) ord[sprintf("%c", n)] = n }
    {
      s = $0
      sub("^/" key "[ ]*", "", s)
      delim = substr(s, 1, 1)
      s = substr(s, 2, length(s) - 2)
      if (delim == "<") {
        out = toupper(s)
      } else {
        out = ""
        i = 1
        while (i <= length(s)) {
          c = substr(s, i, 1)
          if (c == "\\") {
            oct = substr(s, i + 1, 3)
            if (oct ~ /^[0-7][0-7][0-7]$/) {
              v = 0
              for (k = 1; k <= 3; k++) { v = v * 8 + (substr(oct, k, 1) + 0) }
              out = out sprintf("%02X", v)
              i += 4
              continue
            }
            c = substr(s, i + 1, 1)
            i += 2
          } else {
            i += 1
          }
          out = out sprintf("%02X", ord[c])
        }
      }
      sub(/^FEFF/, "", out)
      print out
    }'
}

# Read one fixture's Info string and check it against the expected value. The
# reading and the checking are separate from the two-path comparison below, and
# the value is kept whether or not it matched: a run where both paths are wrong
# in the same way and a run where they disagree are different defects, and this
# suite should be able to say which one it is looking at.
read_info() {
  local job="$1" key="$2" expected="$3" found

  found="$(info_hex "$work/$job.pdf" "$key")"
  if [ -z "$found" ]; then
    record_failure "$job: no single string-valued /$key, so its check proves nothing"
    return 1
  fi
  if [ "$found" != "$expected" ]; then
    record_failure "$job has /$key $found, expected $expected"
  else
    echo "  $job: /$key $found"
  fi
  printf '%s\n' "$found" >"$work/$job.$key"
}

# The UTF-16BE code units an ASCII string encodes, as uppercase hex.
#
# Expected values are built from the string here rather than copied out of a
# build, so a fixture cannot pass by agreeing with whatever the package
# currently emits. Only awk is used: iconv and xxd are not guaranteed on the
# CI image, and every string this is applied to is ASCII by fixture design.
ascii_utf16be_hex() {
  printf '%s' "$1" | awk '
    BEGIN { for (n = 32; n < 127; n++) ord[sprintf("%c", n)] = n }
    {
      out = ""
      for (i = 1; i <= length($0); i++) { out = out sprintf("00%02X", ord[substr($0, i, 1)]) }
      print out
    }'
}

title_default=""
title_tagged=""
if compile_fixture letter-title-default.tex letter-title-default; then
  read_info letter-title-default Title "$expected_title_hex" &&
    title_default="$(cat "$work/letter-title-default.Title")"
fi
if compile_fixture letter-title-tagged.tex letter-title-tagged; then
  read_info letter-title-tagged Title "$expected_title_hex" &&
    title_tagged="$(cat "$work/letter-title-tagged.Title")"
fi
# The issue's own assertion, stated in its own right rather than inferred from
# the two above. Both halves must have been read for the paths to be said to
# agree, so a fixture that stopped building cannot make this pass by silence.
if [ -n "$title_default" ] && [ -n "$title_tagged" ]; then
  if [ "$title_default" = "$title_tagged" ]; then
    echo "  both paths agree"
  else
    record_failure "the two build paths derive different /Title strings"
  fi
else
  record_failure "one of the two paths produced no /Title to compare"
fi
echo

echo "== a document's own /Title and /Author survive on both paths =="
# Issue #440, and the counterpart to the section above: that one is about the
# value this package derives, this one about the value it must not derive.
#
# The tagged half is the fixture the bug was reported against. hyperref's
# \DocumentMetadata driver writes pdftitle and pdfauthor into the kernel's PDF
# management and leaves \@pdftitle and \@pdfauthor defined and empty, which is
# exactly what an unset field looks like, so the detector read "the document
# supplied nothing" and the derived values overwrote the user's. Nothing was
# logged and the document compiled cleanly.
#
# The default half is not ceremony either. docs/API.md promises this behaviour
# without qualifying the path, and the fix adds a second reading to a detector
# the default path also runs through; a regression that traded one path for the
# other would otherwise pass. It is the "unchanged, shown rather than asserted"
# half of the issue's acceptance criteria.
expected_override_title_hex="$(ascii_utf16be_hex 'Override Fixture Title')"
expected_override_author_hex="$(ascii_utf16be_hex 'Override Fixture Author')"
for job in letter-override-default letter-override-tagged; do
  if compile_fixture "$job.tex" "$job"; then
    read_info "$job" Title "$expected_override_title_hex"
    read_info "$job" Author "$expected_override_author_hex"
  fi
done
echo

if [ "$fail" -eq 0 ]; then
  echo "ALL METADATA FIXTURES PASSED"
else
  echo "METADATA FIXTURES FAILED"
fi
exit "$fail"
