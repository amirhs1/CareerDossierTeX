#!/usr/bin/env bash
# run.sh -- tagged-PDF structure, extraction, and PDF/UA-2 validation checks.
#
# Issue #28 established the structural half of this suite: semantic
# headings/lists/paragraphs/links, artifact-marked decoration and pagination,
# logical extraction order, an absent structure tree when tagging is not
# requested, and equivalent tagged/untagged word geometry.
#
# Issue #77 adds the release gates that #28 deliberately deferred:
#
#   * PDF/UA-2 validation. Each profile has a *-ua2.tex variant that shares the
#     body include and only adds pdfstandard=ua-2, so a veraPDF result here
#     describes the same output the structural checks assert on.
#   * A three-extractor matrix. Poppler, MuPDF, and Apple PDFKit each impose
#     their own line structure on multi-column entry headers, so each keeps its
#     own committed baseline rather than sharing one. Agreement across three
#     independent implementations is what makes "reading order is preserved" a
#     claim about the PDF rather than about one library's heuristics.
#   * A toolchain record, because a validation result is only meaningful
#     alongside the versions that produced it.
#
# Issue #302 adds a check that is not an extraction check at all. All three
# extractors above rebuild words from glyph geometry, which makes the entire
# matrix blind to two pieces of content separated by nothing but positioning
# glue. structure-text.pl decodes the marked-content runs from the content
# stream instead, consulting no coordinate, so what it reports is the logical
# text of a structure element. It needs no tool beyond Perl, so unlike the
# gates below it never skips.
#
# Screen-reader review (VoiceOver, NVDA) stays manual and is NOT run here; see
# docs/ATS-EXTRACTION.md for the checklists and recorded results.
#
# Scope: these fixtures validate four named artifacts. Passing them is not a
# PDF/UA, WCAG, accessibility, or ATS conformance claim for arbitrary user
# documents.
#
# Requirements: lualatex, pdftotext, and pdfinfo (Poppler) are required.
# veraPDF, MuPDF (mutool), Biber, and PDFKit (macOS) gates are skipped with a
# notice when unavailable, and the closing summary lists exactly which gates
# did not run.
#
# Regenerate extraction baselines intentionally with:  ./run.sh --update
#
# Usage:
#   ./run.sh                    every fixture group — the full suite, and what CI runs
#   ./run.sh <pattern>          only the fixture groups matching <pattern>
#   ./run.sh --list [<pattern>] print the selection and compile nothing
#   ./run.sh --update [<pat>]   regenerate the selected baselines
#
# or, through the Makefile:  make tagging FIXTURE=<pattern>
#
# The selectable unit is the fixture GROUP, not the .tex file (issue #367).
#
# A group is a base fixture plus the companions that mean nothing on their own:
# `<group>-untagged.tex', which exists to be compared against the tagged build,
# and `<group>-ua2.tex', which shares the group's `<group>-body.inc.tex' so a
# veraPDF verdict describes the same output the structural checks assert on.
# check_untagged and check_visual_equivalence are claims about the *pair*, so a
# selection that could separate the members would let a run assert less than it
# appears to. Twelve groups are backed by 37 .tex files for that reason, which
# is also why tests/lint/run-fixture-filter.sh cannot hold this suite to the
# name-per-file universe check it applies to the other four.
set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../.." && pwd)"
work="${TMPDIR:-/tmp}/careerdossier-tagging-$$"
trap 'rm -rf "$work"' EXIT
mkdir -p "$work"

# veraPDF reports are evidence and are retained as CI artifacts, never
# committed. Default inside the repository so `make tagging` leaves them where
# the workflow can upload them; .gitignore excludes the directory.
reports="${CDOSSIER_TAGGING_REPORTS:-$here/reports}"
mkdir -p "$reports"

export TEXINPUTS="$here:$root:${TEXINPUTS:-}"
# The BibLaTeX feasibility fixture reuses the committed bibliography fixture's
# database rather than duplicating it.
export BIBINPUTS="$root/tests/bibliography:${BIBINPUTS:-}"

# Fixture-group selection (issue #367), the interface issue #359 gave the other
# four runners. The pattern is a shell glob matched anywhere in the group name,
# so `cv' behaves as a substring search and `resume-*' anchors at the start; it
# is left unquoted in the `case' below for exactly that reason.
#
# With no pattern every group runs and nothing about this suite has changed —
# that is the invocation CI and `make check' make, and the one the closing line
# must stay byte-identical for.
#
# A pattern selecting nothing exits nonzero rather than reporting a clean run.
# Every assertion here is made per fixture, so a run with no fixtures passes all
# of them and is indistinguishable from a suite that checked something.
#
# `--update' composes with a pattern, as the extraction runner's does: a
# baseline regeneration should rewrite only the baselines the change was meant
# to move.
fixture_filter=""
list_only=0
update=0
for arg in "$@"; do
  case "$arg" in
    --update) update=1 ;;
    --list)   list_only=1 ;;
    -*)       echo "unknown option: $arg" >&2; exit 2 ;;
    *)        fixture_filter="$arg" ;;
  esac
done

# The five profiles driven by the shared loop, then the standalone groups in the
# order they run. This array is the suite's fixture universe: `--list' prints it,
# every block below is gated on it, and tests/lint/run-fixture-filter.sh asserts
# it against the .tex files on disk in both directions.
profiles=(resume cv letter academic-letter statement)
groups=(
  "${profiles[@]}"
  resume-contact-labels
  resume-entrymeta-inline
  resume-linkdecoration
  letter-recipient-address
  cv-subsection
  resume-displaydoctitle-off
  biblatex-ua2
)

selected=()
for group in "${groups[@]}"; do
  if [ -z "$fixture_filter" ]; then
    selected+=("$group")
  else
    case "$group" in
      *$fixture_filter*) selected+=("$group") ;;
    esac
  fi
done

if [ "${#selected[@]}" -eq 0 ]; then
  echo "NO FIXTURE MATCHES '$fixture_filter' (of ${#groups[@]} in $here)."
  echo "  ./run.sh --list  prints every available fixture group name."
  exit 1
fi

if [ "$list_only" -eq 1 ]; then
  printf '%s\n' "${selected[@]}"
  exit 0
fi

group_selected() {
  local group
  for group in ${selected[@]+"${selected[@]}"}; do
    [ "$group" = "$1" ] && return 0
  done
  return 1
}

# Appended to the closing verdict so a filtered run can never be read as a full
# one. Empty for a full run, which keeps that line byte-identical to before.
scope_note=""
if [ -n "$fixture_filter" ]; then
  scope_note=" (filter '$fixture_filter': ${#selected[@]} of ${#groups[@]} fixture groups — NOT a full run)"
  echo "filter '$fixture_filter': ${#selected[@]} of ${#groups[@]} fixture groups selected"
  echo
fi

fail=0
skipped=()
# Groups that were selected and then ran nothing at all, because the only gate
# they have is unavailable here. Without this a scoped run that selected one
# such group would print the same closing line as a scoped run that checked it
# (issue #367). Populated only under a filter: unfiltered, a gate that did not
# run is already named in `skipped', and adding a second notice there would
# change the full-run output this change is required to leave alone.
gated_out=()

for command in lualatex pdftotext pdfinfo; do
  if ! command -v "$command" >/dev/null 2>&1; then
    echo "MISSING required command: $command"
    exit 1
  fi
done

# Optional gates. Probe once rather than per fixture.
have_verapdf=0
if command -v verapdf >/dev/null 2>&1; then
  have_verapdf=1
else
  skipped+=("veraPDF PDF/UA-2 validation (verapdf not installed)")
fi

# veraPDF is the one gate here that runs on a JVM, and the JVM does not read
# $TMPDIR: on Darwin it asks confstr(_CS_DARWIN_USER_TEMP_DIR) for the per-user
# temp directory directly. Under a restricted sandbox that directory is denied,
# and veraPDF dies in its own static initialiser before validating anything:
#
#   Caused by: java.nio.file.FileSystemException:
#     /var/folders/…/T/7478532095515290837: Operation not permitted
#
# Every `verapdf` call below then fails, and the runner reports each fixture as
# `failed veraPDF UA-2 validation` — eleven validation verdicts from a validator
# that never started, which is this repository's characteristic failure wearing
# its other face: not a hollow pass but a hollow failure. Point the JVM at the
# temp directory the rest of this suite already uses ($work is under it), so the
# verdicts come from a validator that ran.
#
# Appended rather than assigned, so a caller's own _JAVA_OPTIONS survives; the
# JVM applies the last occurrence of a repeated -D. It splits the variable on
# whitespace, so a temp path containing a space would arrive as two unparsable
# options and reintroduce the failure this prevents — left alone in that case,
# which is no worse than before and is not silent, since the JVM's startup error
# still names the directory.
if [ "$have_verapdf" -eq 1 ]; then
  jvm_tmpdir="${TMPDIR:-/tmp}"
  case "$jvm_tmpdir" in
    *[[:space:]]*)
      echo "note: TMPDIR contains whitespace; not setting veraPDF's java.io.tmpdir."
      echo "      Under a restricted sandbox veraPDF may fail to start."
      echo
      ;;
    *)
      export _JAVA_OPTIONS="${_JAVA_OPTIONS:+$_JAVA_OPTIONS }-Djava.io.tmpdir=$jvm_tmpdir"
      ;;
  esac
fi

have_mutool=0
if command -v mutool >/dev/null 2>&1; then
  have_mutool=1
else
  skipped+=("MuPDF extraction (mutool not installed)")
fi

# PDFKit is the consumer path behind Preview, Quick Look, Spotlight, Safari, and
# macOS copy/paste. macOS only.
have_pdfkit=0
if [ "$(uname -s)" = Darwin ] && command -v osascript >/dev/null 2>&1; then
  have_pdfkit=1
else
  skipped+=("PDFKit extraction (not macOS, or osascript missing)")
fi

have_biber=0
if command -v biber >/dev/null 2>&1 && command -v latexmk >/dev/null 2>&1; then
  have_biber=1
else
  skipped+=("tagged-BibLaTeX feasibility fixture (biber or latexmk missing)")
fi

normalize() {
  tr -d '\f' | awk '{ line[NR] = $0 }
                      END { last = NR
                            while (last > 0 && line[last] ~ /^[[:space:]]*$/) last--
                            for (i = 1; i <= last; i++) print line[i] }'
}

# MuPDF additionally drops blank lines.
#
# mutool's blank-line placement inside a two-column entry header is version and
# platform dependent: 1.24.9 on macOS emits one between the dates and the
# organization, while the build in Debian's mupdf-tools does not. Word sequence,
# Unicode, and order are identical either way — that difference was the only one
# between local and CI output when this suite first ran on Linux.
#
# MuPDF's job in this matrix is to be an independent opinion on reading order,
# so pinning its exact vertical whitespace would assert a property of the
# extractor build rather than of the PDF. Line content and line order stay fully
# asserted; only empty lines are dropped. Poppler's baseline keeps its blank
# lines and continues to pin exact spacing.
normalize_mupdf() {
  normalize | sed -E 's/[[:space:]]+$//' | grep -v '^[[:space:]]*$'
}

record_failure() {
  echo "  FAIL: $1"
  fail=1
}

# A validation result without the toolchain that produced it is not reviewable
# evidence. Issue #77 requires these versions be recorded with the results.
record_toolchain() {
  {
    echo "# CareerDossierTeX tagging-validation toolchain record"
    echo "date-utc: $(date -u +'%Y-%m-%dT%H:%M:%SZ')"
    echo "os:       $(uname -sr)"
    echo "commit:   $(git -C "$root" rev-parse HEAD 2>/dev/null || echo unavailable)"
    echo
    echo "## engine"
    lualatex --version 2>&1 | head -2
    echo
    echo "## LaTeX format and tagging support"
    for package in pdfmanagement-testphase.sty tagpdf.sty; do
      path="$(kpsewhich "$package" 2>/dev/null)"
      if [ -n "$path" ]; then
        echo "$package -> $path"
        grep -A1 -m1 'ProvidesExplPackage' "$path" 2>/dev/null || true
      else
        echo "$package -> NOT-FOUND"
      fi
    done
    echo
    echo "## validators and extractors"
    if [ "$have_verapdf" -eq 1 ]; then
      verapdf --version 2>/dev/null | grep -i '^veraPDF' || echo "verapdf: version unreported"
    else
      echo "verapdf: NOT-INSTALLED"
    fi
    pdftotext -v 2>&1 | head -1
    if [ "$have_mutool" -eq 1 ]; then
      echo "mutool version $(mutool -v 2>&1 | head -1 | sed 's/^mutool version //')"
    else
      echo "mutool: NOT-INSTALLED"
    fi
    if [ "$have_pdfkit" -eq 1 ]; then
      echo "PDFKit: available (macOS $(sw_vers -productVersion 2>/dev/null || echo unknown))"
    else
      echo "PDFKit: unavailable on this platform"
    fi
    if [ "$have_biber" -eq 1 ]; then
      biber --version 2>&1 | head -1
    else
      echo "biber: NOT-INSTALLED"
    fi
  } | tee "$reports/toolchain.txt"
  echo
}

compile_fixture() {
  local source="$1" job="$2"
  local pass unexpected
  for pass in 1 2; do
    if ! lualatex -output-directory="$work" -jobname="$job" \
        -halt-on-error -interaction=nonstopmode "$here/$source" \
        >"$work/$job.stdout" 2>&1; then
      record_failure "$source did not compile on pass $pass (see $work/$job.stdout)"
      return 1
    fi
  done

  unexpected="$(grep -iE \
    'Warning:|Missing character|Font shape.*undefined|substituting|Undefined control sequence|Overfull' \
    "$work/$job.log" | grep -viE 'Neither unicode-math nor lua-unicode-math' || true)"
  if [ -n "$unexpected" ]; then
    record_failure "$source produced unexpected log diagnostics"
    printf '%s\n' "$unexpected" | sed 's/^/    /'
    return 1
  fi
}

check_structure() {
  local base="$1"
  local pdf="$work/$base.pdf"

  grep -qa 'StructTreeRoot' "$pdf" || record_failure "$base has no structure tree"
  grep -qa '/S /Link' "$pdf" || record_failure "$base has no semantic Link"
  grep -qa '/S /text' "$pdf" || record_failure "$base has no semantic paragraph text"
  grep -qa '/Artifact<</Type /Layout>> BDC' "$pdf" \
    || record_failure "$base has no Layout artifact"

  if [ "$base" = resume ] || [ "$base" = cv ] || [ "$base" = statement ]; then
    grep -qa '/S /section' "$pdf" || record_failure "$base has no semantic section heading"
    grep -Fqa '/section [/H1' "$pdf" || record_failure "$base section is not role-mapped to H1"
  fi

  if [ "$base" = resume ] || [ "$base" = cv ]; then
    grep -qa '/S /itemize' "$pdf" || record_failure "$base has no semantic list"
    grep -qa '/S /item ' "$pdf" || record_failure "$base has no semantic list item"
    grep -qa '/S /itembody' "$pdf" || record_failure "$base has no semantic list-item body"
  fi

  grep -qa '/Artifact BMC' "$pdf" \
    || record_failure "$base running header/folio are not artifacts"

  check_heading_hierarchy "$base" "$pdf"
  check_section_divisions "$base" "$pdf"
  check_identity_title "$base" "$pdf"
}

# Issue #268: a heading element records that some words are a heading. It does
# not record where the section it names begins or ends -- that is the enclosing
# `Sect' division, and without one every heading and every paragraph is a flat
# sibling with nothing tying content to the heading that introduces it.
#
# veraPDF UA-2 passes either way, so this count is the only thing that sees it.
# Before the fix, résumé and CV emitted zero divisions around two headings each
# while the statement, which keeps the kernel's `\@startsection', emitted two.
#
# The expected number is per profile and is stated rather than derived, so a
# fixture that loses a section fails here instead of quietly lowering the bar.
# `/Sect' is anchored to its own `/S ' key, and no other structure name in this
# suite has it as a prefix, so a plain count is exact.
check_section_divisions() {
  local base="$1" pdf="$2"
  local expected sections

  case "$base" in
    resume|cv|statement) expected=2 ;;
    # The letters are continuous prose with no sectioning at all.
    letter|academic-letter) expected=0 ;;
    *) return ;;
  esac

  sections="$(grep -oaF '/S /Sect' "$pdf" | wc -l | tr -d '[:space:]')"
  [ "$sections" -eq "$expected" ] \
    || record_failure \
      "$base has $sections Sect division(s) around its section headings, expected $expected"

  # Each heading must record its own text as the element's `/T', as the
  # statement's kernel headings already do -- a division that encloses the
  # right content but names nothing would otherwise pass the count above.
  #
  # A PDF text string is stored as UTF-16BE hex with a byte-order mark, not as
  # readable characters, so the expected form is encoded rather than written
  # out; grepping for the plain words would match nothing and pass vacuously.
  case "$base" in
    resume)  check_heading_title "$base" "$pdf" 'Additional Experience' ;;
    cv)      check_heading_title "$base" "$pdf" 'Teaching Experience' ;;
    statement) check_heading_title "$base" "$pdf" 'Future Programme' ;;
  esac
}

# Issue #305: the identity heading is the document's /H1 -- it outranks every
# section heading in every family -- so it must carry a title at least as much
# as the headings beneath it do. #268 gave section headings their `/T' and left
# the identity without one, which is the inconsistency this closes.
#
# The name is asserted per profile from the fixture's own `name' field rather
# than from a shared constant, so a fixture that changes its name fails here
# instead of silently checking someone else's string. The letters carry no
# section heading at all, which makes their identity the only titled element in
# the document and this the only check that sees it.
check_identity_title() {
  local base="$1" pdf="$2"
  local name

  case "$base" in
    resume)          name='Tagged Industry Resume' ;;
    cv)              name='Tagged Academic CV' ;;
    letter)          name='Tagged Industry Letter' ;;
    academic-letter) name='Tagged Academic Letter' ;;
    statement)       name='Tagged Research Statement' ;;
    *) return ;;
  esac

  check_heading_title "$base" "$pdf" "$name"

  # The statement's title line is a depth-2 heading of its own, rendered by the
  # class rather than by \CDossierSection, so it needs naming separately.
  if [ "$base" = statement ]; then
    check_heading_title "$base" "$pdf" 'Research Statement'
  fi
}

check_heading_title() {
  local base="$1" pdf="$2" title="$3"
  local hex

  hex="$(perl -e 'use Encode; print uc unpack("H*", encode("UTF-16", $ARGV[0]))' "$title")"
  grep -Fqa "/T <$hex>" "$pdf" \
    || record_failure "$base does not record '$title' as its heading element's title"
}

# Issue #267: the document identity (the name) is depth 1 of the shared
# heading primitive -- the kernel's dflt namespace maps that depth to `/H1' --
# so it must be the document's *only* `/H1', and it must outrank every other
# heading. Every one of the five named profiles carries exactly one `/S
# /section' element (the name); a résumé/CV/statement section heading is `/S
# /subsection' (`/H2') and a statement subsection would be `/S /subsubsection'
# (`/H3'). These three literal tags cannot collide as substrings of one
# another once each is anchored to its own `/S ' key, so a plain count is
# enough to catch both a missing identity heading and a skipped level.
check_heading_hierarchy() {
  local base="$1" pdf="$2"
  local h1 h2 h3

  h1="$(grep -oaF '/S /section' "$pdf" | wc -l | tr -d '[:space:]')"
  h2="$(grep -oaF '/S /subsection' "$pdf" | wc -l | tr -d '[:space:]')"
  h3="$(grep -oaF '/S /subsubsection' "$pdf" | wc -l | tr -d '[:space:]')"

  [ "$h1" -eq 1 ] \
    || record_failure "$base has $h1 /H1-mapped heading(s) (the identity name), expected exactly 1"
  if [ "$h3" -gt 0 ] && [ "$h2" -eq 0 ]; then
    record_failure "$base has an /H3-mapped heading with no /H2 beneath /H1 -- a skipped level"
  fi
}

# Issue #337: the record classes' second heading level, as the structure tree
# sees it. check_heading_hierarchy above states the rule this enforces — an /H3
# with no /H2 is a skipped level — but every fixture that runs it has zero /H3
# elements, so its `h3 > 0' branch has never been reached by anything. This is
# the fixture that reaches it, and it asserts the positive form rather than the
# absence of a violation.
#
# Three counts, because the failures they separate are different. A subsection
# that reused depth 2 gives the right total heading count and the wrong shape; a
# subsection that opened no division encloses nothing; and a subsection whose
# division replaced its parent's rather than nesting inside it leaves the section
# count short. The fixture has two sections and three subsections, so the five
# divisions are what nesting produces and four is what replacement produces.
check_subsection_hierarchy() {
  local base="$1"
  local pdf="$work/$base.pdf"
  local h1 h2 h3 sections

  h1="$(grep -oaF '/S /section' "$pdf" | wc -l | tr -d '[:space:]')"
  h2="$(grep -oaF '/S /subsection' "$pdf" | wc -l | tr -d '[:space:]')"
  h3="$(grep -oaF '/S /subsubsection' "$pdf" | wc -l | tr -d '[:space:]')"
  sections="$(grep -oaF '/S /Sect' "$pdf" | wc -l | tr -d '[:space:]')"

  [ "$h1" -eq 1 ] \
    || record_failure "$base has $h1 /H1-mapped heading(s) (the identity name), expected exactly 1"
  [ "$h2" -eq 2 ] \
    || record_failure "$base has $h2 /H2-mapped section heading(s), expected 2"
  [ "$h3" -eq 3 ] \
    || record_failure "$base has $h3 /H3-mapped subsection heading(s), expected 3"
  [ "$sections" -eq 5 ] \
    || record_failure \
      "$base has $sections Sect division(s) around 2 sections and 3 subsections, expected 5"

  grep -Fqa '/subsubsection [/H3' "$pdf" \
    || record_failure "$base subsection is not role-mapped to H3"

  check_heading_title "$base" "$pdf" 'Conference Papers'
}

check_two_page_furniture() {
  local base="$1"
  local pdf="$work/$base.pdf"
  local pages page_one page_two running_label

  pages="$(pdfinfo "$pdf" | awk '/^Pages:/ { print $2 }')"
  if [ "$pages" -ne 2 ]; then
    record_failure \
      "$base must have exactly two pages for continuation-furniture coverage (got $pages)"
    return
  fi

  page_one="$(pdftotext -enc UTF-8 -f 1 -l 1 "$pdf" - | tr -d '\f')"
  page_two="$(pdftotext -enc UTF-8 -f 2 -l 2 "$pdf" - | tr -d '\f')"
  printf '%s\n' "$page_one" | grep -Fqx "Page 1 of 2" \
    || record_failure "$base page one has no folio"

  case "$base" in
    cv)
      running_label="Curriculum Vitae"
      printf '%s\n' "$page_two" | grep -Fq "Tagged Academic CV" \
        || record_failure "cv page two has no running header"
      printf '%s\n' "$page_two" | grep -Fq "$running_label" \
        || record_failure "cv page two has no running label"
      printf '%s\n' "$page_two" | grep -Fqx "Page 2 of 2" \
        || record_failure "cv page two has no folio"
      ;;
    academic-letter)
      running_label="Cover Letter"
      printf '%s\n' "$page_two" | grep -Fq "Tagged Academic Letter" \
        || record_failure "academic-letter page two has no running header"
      printf '%s\n' "$page_two" | grep -Fq "$running_label" \
        || record_failure "academic-letter page two has no running label"
      printf '%s\n' "$page_two" | grep -Fqx "Page 2 of 2" \
        || record_failure "academic-letter page two has no folio"
      ;;
    statement)
      running_label="Research Programme"
      printf '%s\n' "$page_two" | grep -Fq "Tagged Research Statement" \
        || record_failure "statement page two has no running header"
      printf '%s\n' "$page_two" | grep -Fq "$running_label" \
        || record_failure "statement page two has no running label"
      printf '%s\n' "$page_two" | grep -Fqx "Page 2 of 2" \
        || record_failure "statement page two has no folio"
      ;;
    resume)
      running_label="Résumé"
      printf '%s\n' "$page_two" | grep -Fq "Tagged Industry Resume" \
        || record_failure "resume page two has no running header"
      printf '%s\n' "$page_two" | grep -Fq "$running_label" \
        || record_failure "resume page two has no running label"
      printf '%s\n' "$page_two" | grep -Fqx "Page 2 of 2" \
        || record_failure "resume page two has no folio"
      ;;
    letter)
      running_label="Cover Letter"
      printf '%s\n' "$page_two" | grep -Fq "Tagged Industry Letter" \
        || record_failure "letter page two has no running header"
      printf '%s\n' "$page_two" | grep -Fq "$running_label" \
        || record_failure "letter page two has no running label"
      printf '%s\n' "$page_two" | grep -Fqx "Page 2 of 2" \
        || record_failure "letter page two has no folio"
      ;;
  esac

  if printf '%s\n' "$page_one" | grep -Fq "$running_label"; then
    record_failure "$base page one unexpectedly contains its running label"
  fi
}

check_page_two_artifact_stream() {
  local base="$1"
  local text_artifacts

  [ "$have_mutool" -eq 1 ] || return

  # A tagged page contains empty artifact wrappers even when its page style has
  # no visible furniture. Count only Artifact BMC blocks that contain a text
  # object before their closing EMC. Every page-two fixture must have exactly
  # two such blocks: one running header and one folio.
  text_artifacts="$(
    mutool show "$work/$base.pdf" pages/2/Contents \
      | awk '
          /^\/Artifact BMC$/ { in_artifact = 1; next }
          in_artifact && /^BT$/ { count++; in_artifact = 0; next }
          in_artifact && /^EMC$/ { in_artifact = 0 }
          END { print count + 0 }
        '
  )"

  [ "$text_artifacts" -eq 2 ] \
    || record_failure \
      "$base page two must artifact-mark its header and folio (found $text_artifacts text artifacts)"
}

# Tagged + labelled contact line (issue #125).
#
# The contract in careerdossier-components.sty is that a contact label and an
# unlinked contact value are meaningful content that must reach the structure
# tree, while the " | " separator between items is a layout artifact. veraPDF
# cannot decide this: an artifact is structurally legal, so text wrongly marked
# as one still validates. This check is what distinguishes the two.
#
# It decides by exhaustion rather than by decoding glyph codes. The fixture is
# deliberately one page, so it carries no folio and no running header and has no
# legitimate text furniture. Separators are emitted as /Artifact<</Type /Layout>>
# BDC, which is a different operator from the bare /Artifact BMC counted here.
# Any text object inside a bare artifact on that page is therefore real content
# that assistive technology has been told to skip.
#
# This is the regression that #158 introduced and that shipping v0.6.0 would
# otherwise have carried: every unlinked contact item -- phone, location, and
# every contact label -- was emitted as a bare artifact.
check_contact_label_tagging() {
  local base="$1"
  local pdf="$work/$base.pdf"
  local pages extracted text_artifacts

  pages="$(pdfinfo "$pdf" | awk '/^Pages:/ { print $2 }')"
  if [ "$pages" -ne 1 ]; then
    record_failure \
      "$base must stay one page so the artifact count has no page furniture in it (got $pages)"
    return
  fi

  grep -qa 'StructTreeRoot' "$pdf" || record_failure "$base has no structure tree"

  extracted="$(pdftotext -enc UTF-8 "$pdf" -)"
  printf '%s\n' "$extracted" | grep -Fq 'Email: ' \
    || record_failure "$base lost its Email label in extraction"
  printf '%s\n' "$extracted" | grep -Fq 'Phone: ' \
    || record_failure "$base lost its Phone label in extraction"
  # website is absent from the fixture: no orphan label, no stray separator.
  if printf '%s\n' "$extracted" | grep -Fq 'Website:'; then
    record_failure "$base emitted an orphan Website label for an absent field"
  fi
  if printf '%s\n' "$extracted" | grep -Eq '\|[[:space:]]*$|^[[:space:]]*\|'; then
    record_failure "$base has a stray separator at a contact-line edge"
  fi

  if [ "$have_mutool" -eq 1 ]; then
    text_artifacts="$(
      mutool show "$pdf" pages/1/Contents \
        | awk '
            /^\/Artifact BMC$/ { in_artifact = 1; next }
            in_artifact && /^BT$/ { count++; in_artifact = 0; next }
            in_artifact && /^EMC$/ { in_artifact = 0 }
            END { print count + 0 }
          '
    )"
    [ "$text_artifacts" -eq 0 ] \
      || record_failure \
        "$base marks $text_artifacts text run(s) as bare artifacts; contact labels and unlinked values must be content"
  fi

  # Record the roles this fixture actually produced, so the claim above is
  # reviewable against observed output rather than assumption.
  grep -oa '/S */[A-Za-z0-9]*' "$pdf" | sort | uniq -c | sort -rn \
    >"$reports/$base-structure.txt"
  echo "  RECORDED: structure roles (report: $base-structure.txt)"
}

# Underlined link text under `medium=screen' (issue #278).
#
# The decoration is drawn by ulem, and \uline reboxes what it underlines. Boxed
# text under tagging is exactly how the v0.6.0 regression of issue #161
# happened: the run became a bare /Artifact, invisible to assistive technology,
# while veraPDF validated it and all three extractors read it back intact. So
# neither veraPDF nor the extraction matrix can be the guard here.
#
# Two assertions, and the second is the one that would have caught #161:
#
#   1. The anchor text reaches the structure tree as content. check_structure_text
#      pins the full decoded run set; this names the decorated run specifically,
#      so a diff that loses it cannot be waved through by regenerating a baseline.
#   2. No text object sits inside a bare /Artifact BMC. The fixture is one page
#      and `medium=screen' emits no furniture at all, so it has no legitimate
#      text artifact of any kind — the count must be exactly zero. The " | "
#      contact separators are /Artifact<</Type /Layout>> BDC, a different
#      operator, and are not counted.
check_link_decoration_tagging() {
  local base="$1"
  local anchor="$2"
  local pdf="$work/$base.pdf"
  local got="$work/$base.structure.got"
  local pages text_artifacts

  pages="$(pdfinfo "$pdf" | awk '/^Pages:/ { print $2 }')"
  if [ "$pages" -ne 1 ]; then
    record_failure \
      "$base must stay one page so the artifact count has no page furniture in it (got $pages)"
    return
  fi

  grep -qa 'StructTreeRoot' "$pdf" || record_failure "$base has no structure tree"

  if [ -s "$got" ]; then
    if grep -Fq "$anchor" "$got"; then
      echo "  VERIFIED: underlined anchor text '$anchor' is structure content"
    else
      record_failure \
        "$base structure text has no '$anchor': the underlined anchor text is not reaching the structure tree"
    fi
  fi

  if [ "$have_mutool" -eq 1 ]; then
    text_artifacts="$(
      mutool show "$pdf" pages/1/Contents \
        | awk '
            /^\/Artifact BMC$/ { in_artifact = 1; next }
            in_artifact && /^BT$/ { count++; in_artifact = 0; next }
            in_artifact && /^EMC$/ { in_artifact = 0 }
            END { print count + 0 }
          '
    )"
    if [ "$text_artifacts" -eq 0 ]; then
      echo "  VERIFIED: no text run is a bare artifact (issue #161 hazard)"
    else
      record_failure \
        "$base marks $text_artifacts text run(s) as bare artifacts; underlined link text must stay content"
    fi
  fi
}

# Structure-element text (issue #302).
#
# Every other extraction check below asks an extractor what the page says, and
# Poppler, MuPDF, and PDFKit all rebuild words and lines from glyph *geometry*.
# That makes the whole matrix blind to one class of defect: two pieces of
# content separated by nothing but positioning glue. `\hfill' and `\\' move the
# pen by an absolute coordinate jump and emit no character, so an entry
# heading's title and dates landed in one marked-content run as the literal
# string `Engineer2024-2026' -- while every baseline here stayed green, because
# Poppler sees the horizontal gap and splits the two onto separate lines
# anyway. A consumer that reads the structure tree's own text gets the glued
# string; the suite never saw it.
#
# structure-text.pl decodes the content stream directly and consults no
# coordinate at all, so what it prints is exactly what such a consumer reads.
#
# There are two assertions here and they fail for different reasons on purpose.
# The committed baseline pins every run, so any change to the tagged text is
# visible; the explicit separator assertions state the invariant in words, so
# the specific defect cannot be waved through by regenerating a baseline. A
# baseline is only as good as the review of its diff, and this defect is a
# single missing space.
check_structure_text() {
  local base="$1"
  local pdf="$work/$base.pdf"
  local got="$work/$base.structure.got"
  local expected="$here/$base.structure.txt"

  if ! perl "$here/structure-text.pl" "$pdf" >"$got" 2>"$got.err"; then
    record_failure "$base structure-element text could not be decoded"
    sed 's/^/    /' "$got.err"
    return
  fi

  check_one_extractor "$base" "structure text" "$expected" "$got"
}

# Assert that a decoded run contains a real separator between two cells whose
# only visual separation is glue. The glued form is named explicitly rather
# than derived, so the failure message says what went wrong.
#
# Arguments: base, then "separated form|glued form" pairs.
check_structure_text_separators() {
  local base="$1"; shift
  local got="$work/$base.structure.got"
  local pair separated glued

  [ -s "$got" ] || return

  for pair in "$@"; do
    separated="${pair%%|*}"
    glued="${pair##*|}"
    if grep -Fq "$glued" "$got"; then
      record_failure \
        "$base structure text contains '$glued': the two cells are glued together with no separator"
    elif ! grep -Fq "$separated" "$got"; then
      record_failure \
        "$base structure text has neither '$separated' nor the glued form; the fixture changed"
    fi
  done
}

# The `entrymeta=inline' form of the assertion above (issue #230).
#
# It needs its own function because the inline separator is a marked-content
# artifact, and an artifact interrupts the enclosing run: `Engineer | 2024-2026'
# decodes as the two runs `Engineer ' and `2024-2026' rather than as one. The
# per-line grep above would therefore find neither the separated form nor the
# glued one and report the fixture as changed, which is not what happened. So
# the runs are concatenated in document order first, which is exactly what a
# consumer reading the structure tree's logical text does, and the assertions
# are made against that string.
#
# Three forms per join, and all three are named rather than derived, because
# each fails for a different reason:
#
#   separated  what the joined text must be — and it is character-for-character
#              what the `column' form of the same heading produces, which is the
#              claim `entrymeta' rests on: it moves ink, not structure.
#   glued      issue #302 all over again. It would mean the leading space is not
#              reaching the content stream as a real U+0020, so the two cells
#              arrive as one word.
#   barred     the `|' itself reaching the structure tree. It would mean the
#              mark is being emitted as content rather than as a layout
#              artifact, and assistive technology would announce a vertical bar
#              between an entry's title and its dates.
#
# Fields are delimited by `::' rather than by `|', which is the delimiter the
# function above uses: the barred form contains a literal `|'.
#
# Arguments: base, then "separated::glued::barred" triples.
check_structure_text_inline_joins() {
  local base="$1"; shift
  local got="$work/$base.structure.got"
  local joined="$work/$base.structure.joined"
  local triple separated glued barred rest

  [ -s "$got" ] || return

  # Field 4 is the decoded text of one structure element. Concatenated with
  # nothing between them, in file order, which is document order.
  awk -F'\t' '{ printf "%s", $4 } END { printf "\n" }' "$got" >"$joined"

  for triple in "$@"; do
    separated="${triple%%::*}"
    rest="${triple#*::}"
    glued="${rest%%::*}"
    barred="${rest#*::}"
    if grep -Fq "$barred" "$joined"; then
      record_failure \
        "$base joined structure text contains '$barred': the inline separator is reaching the structure tree as content instead of as a layout artifact"
    elif grep -Fq "$glued" "$joined"; then
      record_failure \
        "$base joined structure text contains '$glued': the two cells are glued together with no separator"
    elif ! grep -Fq "$separated" "$joined"; then
      record_failure \
        "$base joined structure text has none of '$separated', the glued form, or the barred form; the fixture changed"
    fi
  done
}

# One extractor against its own committed baseline. Poppler, MuPDF, and PDFKit
# disagree on how to linearize the two-column entry header, so each owns a
# baseline; sharing one would only record whichever library ran last.
check_one_extractor() {
  local base="$1" label="$2" expected="$3" got="$4"

  if [ "$update" -eq 1 ]; then
    cp "$got" "$expected"
    echo "  baseline updated: $(basename "$expected")"
    return
  fi
  if [ ! -f "$expected" ]; then
    record_failure "$base missing $label baseline $(basename "$expected") (run with --update)"
    return
  fi
  if ! diff -u "$expected" "$got" >"$got.diff"; then
    record_failure "$base $label extraction differs from $(basename "$expected")"
    sed 's/^/    /' "$got.diff"
  fi
}

check_extraction() {
  local base="$1"

  pdftotext -enc UTF-8 "$work/$base.pdf" - | normalize >"$work/$base.poppler.got"
  check_one_extractor "$base" Poppler "$here/$base.expected.txt" \
    "$work/$base.poppler.got"

  if [ "$have_mutool" -eq 1 ]; then
    mutool draw -F txt -o - "$work/$base.pdf" 2>/dev/null | normalize_mupdf \
      >"$work/$base.mupdf.got"
    check_one_extractor "$base" MuPDF "$here/$base.mupdf.txt" \
      "$work/$base.mupdf.got"
  fi

  if [ "$have_pdfkit" -eq 1 ]; then
    osascript -l JavaScript "$root/tests/extraction/pdfkit-extract.js" \
      "$work/$base.pdf" | normalize >"$work/$base.pdfkit.got"
    check_one_extractor "$base" PDFKit "$here/$base.pdfkit.txt" \
      "$work/$base.pdfkit.got"
  fi
}

check_untagged() {
  local base="$1"
  if grep -qa StructTreeRoot "$work/$base-untagged.pdf"; then
    record_failure "$base-untagged unexpectedly contains a structure tree"
  fi
}

# ViewerPreferences /DisplayDocTitle (issue #277).
#
# A viewer shows the filename in its window title, tab bar, and recent-documents
# list unless the catalog asks it not to, so the /Title careerdossier-components
# derives is present and unused without this flag -- PDF/UA-2 clause 8.11.2 and
# WCAG 2.1 AA 2.4.2. hyperref sets it only for a document that asks, or for
# \DocumentMetadata{...,pdfstandard=ua-2}, which meant the *-ua2.tex variants
# had it and the documented tagged path did not. The check is therefore on the
# plain fixtures, tagged and untagged, and not on the UA-2 ones: those would
# pass on hyperref's doing alone and prove nothing about ours.
check_display_doc_title() {
  local base="$1" variant

  for variant in "$base" "$base-untagged"; do
    grep -Fqa '/DisplayDocTitle true' "$work/$variant.pdf" \
      || record_failure "$variant does not request /DisplayDocTitle"
  done
}

# The other half of the contract: a document that does not want it wins.
#
# The flag is a boolean with no observable unset state, so it cannot be applied
# the way the derived fields are -- there is nothing to detect at
# \begin{document}. It is applied at hyperref load time instead, before any line
# the document itself writes, and an ordinary \hypersetup in the preamble
# overrides it. Nothing else in the suite would notice if that ordering were
# lost.
#
# The /Title assertion is not decoration. This fixture asserts an absence, and an
# absence is also what a compressed catalog would produce; requiring the derived
# title in the same file keeps the check from passing vacuously.
check_display_doc_title_override() {
  local base="$1"
  local pdf="$work/$base.pdf"

  if grep -Fqa '/DisplayDocTitle' "$pdf"; then
    record_failure "$base kept /DisplayDocTitle despite pdfdisplaydoctitle=false"
  fi
  if [ -z "$(pdfinfo "$pdf" | awk -F': +' '/^Title:/ { print $2 }')" ]; then
    record_failure \
      "$base has no derived /Title, so its /DisplayDocTitle check is vacuous"
  fi
}

check_visual_equivalence() {
  local base="$1" tagged="$work/$base.bbox" plain="$work/$base-untagged.bbox"
  # Compare every rendered word and its bounding box with an explicit 0.11pt
  # tolerance. Numeric comparison is required: rounding or truncating decimal
  # strings can turn sub-tenth-point noise across a boundary into a false
  # one-tenth-point failure.
  pdftotext -bbox "$work/$base.pdf" - | grep '<word ' >"$tagged"
  pdftotext -bbox "$work/$base-untagged.pdf" - | grep '<word ' >"$plain"
  if ! perl - "$plain" "$tagged" >"$work/$base-layout.diff" <<'PERL'
use strict;
use warnings;

my ($plain_path, $tagged_path) = @ARGV;
open my $plain_fh, '<', $plain_path or die "open $plain_path: $!";
open my $tagged_fh, '<', $tagged_path or die "open $tagged_path: $!";
my @plain = <$plain_fh>;
my @tagged = <$tagged_fh>;

if (@plain != @tagged) {
  print "word-count mismatch: untagged=", scalar @plain,
    " tagged=", scalar @tagged, "\n";
  exit 1;
}

my $failed = 0;
for my $index (0 .. $#plain) {
  my $pattern = qr{
    <word \s+
    xMin="([0-9.]+)" \s+ yMin="([0-9.]+)" \s+
    xMax="([0-9.]+)" \s+ yMax="([0-9.]+)">
    (.*)
    </word>
  }x;
  my @plain_fields = $plain[$index] =~ $pattern;
  my @tagged_fields = $tagged[$index] =~ $pattern;
  if (@plain_fields != 5 || @tagged_fields != 5) {
    print "unparsed word at index $index\n";
    $failed = 1;
    next;
  }
  if ($plain_fields[4] ne $tagged_fields[4]) {
    print "word mismatch at index $index: '$plain_fields[4]' vs ",
      "'$tagged_fields[4]'\n";
    $failed = 1;
    next;
  }
  for my $coordinate (0 .. 3) {
    my $delta = abs($plain_fields[$coordinate] - $tagged_fields[$coordinate]);
    if ($delta > 0.11) {
      printf "geometry mismatch at word %d ('%s'), coordinate %d: " .
        "%.5f vs %.5f (delta %.5f)\n",
        $index, $plain_fields[4], $coordinate,
        $plain_fields[$coordinate], $tagged_fields[$coordinate], $delta;
      $failed = 1;
    }
  }
}
exit $failed;
PERL
  then
    record_failure "$base tagged/untagged word geometry differs"
    sed 's/^/    /' "$work/$base-layout.diff"
  fi
}

# veraPDF against the UA-2 variant. The XML report is retained as evidence; the
# console line states the verdict. `-f ua2` pins the flavour rather than letting
# veraPDF infer one from metadata, so a fixture that silently stopped declaring
# ua-2 fails here instead of being validated against something weaker.
validate_ua2() {
  # Declared separately: `local` expands every argument before any of its
  # assignments take effect, so `job="$base-ua2" report="...$job..."` would
  # dereference an unset `job` and trip `set -u`.
  local base="$1"
  local job="$base-ua2"
  local report="$reports/$job.xml"

  if ! verapdf -f ua2 --format xml "$work/$job.pdf" >"$report" 2>"$report.stderr"; then
    record_failure "$base-ua2 failed veraPDF UA-2 validation (report: $report)"
    verapdf -f ua2 --format text -v "$work/$job.pdf" 2>/dev/null | sed 's/^/    /'
    return 1
  fi
  echo "  veraPDF UA-2 PASS (report: $(basename "$report"))"
}

# Tagged BibLaTeX, recorded separately and deliberately non-blocking.
#
# Tagging support inside BibLaTeX and Biber is upstream work. Issue #77 scopes
# this fixture to recording current behavior: a failure here is reported and
# retained, but only fails the suite if CareerDossierTeX's own code caused it,
# which is a judgement the maintainer makes from the retained report.
check_biblatex_feasibility() {
  local job=biblatex-ua2

  echo "== $job (feasibility, non-blocking) =="
  if ! (cd "$work" && latexmk -lualatex -interaction=nonstopmode \
      -output-directory="$work" "$here/$job.tex" >"$work/$job.stdout" 2>&1); then
    echo "  RECORDED: $job did not build (see $work/$job.stdout)"
    echo "  Not a release blocker; review before claiming tagged BibLaTeX support."
    return
  fi

  if [ "$have_verapdf" -eq 1 ]; then
    if verapdf -f ua2 --format xml "$work/$job.pdf" \
        >"$reports/$job.xml" 2>"$reports/$job.xml.stderr"; then
      echo "  RECORDED: veraPDF UA-2 PASS (report: $job.xml)"
    else
      echo "  RECORDED: veraPDF UA-2 FAIL (report: $job.xml)"
      echo "  Not a release blocker unless the cause is CareerDossierTeX's own"
      echo "  code. Review the report before claiming tagged BibLaTeX support."
    fi
  else
    echo "  RECORDED: built successfully; veraPDF unavailable to validate it."
  fi

  # Record the structure roles the bibliography actually produced, so the
  # documented limitations describe observed output rather than assumption.
  grep -oa '/S */[A-Za-z0-9]*' "$work/$job.pdf" | sort | uniq -c | sort -rn \
    >"$reports/$job-structure.txt"
  echo "  RECORDED: structure roles (report: $job-structure.txt)"
}

record_toolchain

for base in "${profiles[@]}"; do
  group_selected "$base" || continue
  echo "== $base =="
  compile_fixture "$base.tex" "$base" || continue
  compile_fixture "$base-untagged.tex" "$base-untagged" || continue
  check_structure "$base"
  check_two_page_furniture "$base"
  check_page_two_artifact_stream "$base"
  check_extraction "$base"
  check_structure_text "$base"
  # The two-cell rows this profile actually renders, as "separated|glued".
  # Every one of these passed the extraction baselines above while glued.
  case "$base" in
    resume)
      check_structure_text_separators resume \
        'Engineer 2024–2026|Engineer2024–2026' \
        'Example Labs Toronto|Example LabsToronto' \
        'Senior Engineer 2022–2024|Senior Engineer2022–2024' \
        'Example Services Ottawa|Example ServicesOttawa'
      ;;
    cv)
      check_structure_text_separators cv \
        'Researcher 2023–2026|Researcher2023–2026' \
        'Example University Toronto|Example UniversityToronto' \
        'Instructor 2025|Instructor2025'
      ;;
    letter)
      check_structure_text_separators letter \
        'Casey Reader Example Company|Casey ReaderExample Company'
      ;;
    academic-letter)
      check_structure_text_separators academic-letter \
        'Jordan Reader Example University|Jordan ReaderExample University'
      ;;
  esac
  check_untagged "$base"
  check_display_doc_title "$base"
  check_visual_equivalence "$base"

  if [ "$have_verapdf" -eq 1 ]; then
    compile_fixture "$base-ua2.tex" "$base-ua2" && validate_ua2 "$base"
  fi
done

# The labelled contact line is a one-page header fixture, so it deliberately
# sits outside the five-document loop above: that loop asserts two-page
# continuation furniture, which this fixture must not have. It still runs as
# part of the ordinary suite rather than as a separate manual step.
if group_selected resume-contact-labels; then
echo "== resume-contact-labels =="
if compile_fixture resume-contact-labels.tex resume-contact-labels; then
  check_contact_label_tagging resume-contact-labels
  check_extraction resume-contact-labels

  if [ "$have_verapdf" -eq 1 ]; then
    compile_fixture resume-contact-labels-ua2.tex resume-contact-labels-ua2 \
      && validate_ua2 resume-contact-labels
  fi
fi
fi

# Entry metadata set inline (issue #230). Outside the five-document loop for the
# same reason as the fixture above: it is a one-page document with no
# continuation furniture. The option's rendered and extracted output is pinned
# by tests/extraction; what only this suite can see is what `inline' does to the
# tagged path, which is supposed to be nothing a consumer can tell apart from
# `column' — one artifact per join, and the same logical text either way.
if group_selected resume-entrymeta-inline; then
echo "== resume-entrymeta-inline =="
if compile_fixture resume-entrymeta-inline.tex resume-entrymeta-inline; then
  check_structure_text resume-entrymeta-inline
  check_structure_text_inline_joins resume-entrymeta-inline \
    'Engineer 2024–2026::Engineer2024–2026::Engineer | 2024–2026' \
    'Example Labs Toronto::Example LabsToronto::Example Labs | Toronto' \
    'Example Services Ottawa::Example ServicesOttawa::Example Services | Ottawa'
  check_extraction resume-entrymeta-inline

  if [ "$have_verapdf" -eq 1 ]; then
    compile_fixture resume-entrymeta-inline-ua2.tex resume-entrymeta-inline-ua2 \
      && validate_ua2 resume-entrymeta-inline
  fi
fi
fi

# Link decoration under `medium=screen' (issue #278). Outside the five-document
# loop for the same reason as the two fixtures above: one page, no continuation
# furniture. What only this suite can see is whether ulem's rebox pushed the
# underlined anchor text out of the structure tree.
if group_selected resume-linkdecoration; then
echo "== resume-linkdecoration =="
if compile_fixture resume-linkdecoration.tex resume-linkdecoration; then
  check_structure_text resume-linkdecoration
  check_link_decoration_tagging resume-linkdecoration 'public write-up'
  check_extraction resume-linkdecoration

  if [ "$have_verapdf" -eq 1 ]; then
    compile_fixture resume-linkdecoration-ua2.tex resume-linkdecoration-ua2 \
      && validate_ua2 resume-linkdecoration
  fi
fi
fi

# The full recipient block (issue #302). Outside the loop because it is a
# one-page fixture with no continuation furniture, and because the only thing it
# is here to pin is the recipient block -- including the `\\' the user writes
# inside recipient-address, which no other fixture sets.
if group_selected letter-recipient-address; then
echo "== letter-recipient-address =="
if compile_fixture letter-recipient-address.tex letter-recipient-address; then
  check_structure_text letter-recipient-address
  check_structure_text_separators letter-recipient-address \
    'Casey Reader Head of Engineering|Casey ReaderHead of Engineering' \
    'Head of Engineering Example Company|Head of EngineeringExample Company' \
    'Example Company 123 Discovery Avenue|Example Company123 Discovery Avenue' \
    '123 Discovery Avenue Vancouver, BC V6T 1Z4|123 Discovery AvenueVancouver, BC V6T 1Z4'

  if [ "$have_verapdf" -eq 1 ]; then
    compile_fixture letter-recipient-address-ua2.tex letter-recipient-address-ua2 \
      && validate_ua2 letter-recipient-address
  fi
fi
fi

# The second heading level (issue #337). Outside the five-document loop for the
# same reason as the fixtures above: one page, no continuation furniture.
#
# Everything this fixture is here for is invisible on the rendered page. The
# heading has no rule and no size of its own, so a subsection that emitted a
# second /H2 -- or no heading element at all -- would look exactly right and
# would still flatten the hierarchy for anything reading the structure tree.
if group_selected cv-subsection; then
echo "== cv-subsection =="
if compile_fixture cv-subsection.tex cv-subsection; then
  check_subsection_hierarchy cv-subsection
  check_structure_text cv-subsection

  if [ "$have_verapdf" -eq 1 ]; then
    compile_fixture cv-subsection-ua2.tex cv-subsection-ua2 \
      && validate_ua2 cv-subsection
  fi
fi
fi

# The DisplayDocTitle override sits outside the five-document loop for the same
# reason: it is a one-page fixture with no continuation furniture, and it is the
# only fixture whose preamble contradicts the package on purpose.
if group_selected resume-displaydoctitle-off; then
echo "== resume-displaydoctitle-off =="
if compile_fixture resume-displaydoctitle-off.tex resume-displaydoctitle-off; then
  check_display_doc_title_override resume-displaydoctitle-off
fi
fi

# The feasibility fixture is a selectable group like any other (issue #367). It
# is the one group whose *only* path is behind a gate, so selecting it on a
# machine without Biber runs nothing at all -- recorded below rather than left
# to print as a pass.
if group_selected biblatex-ua2; then
  if [ "$have_biber" -eq 1 ]; then
    echo
    check_biblatex_feasibility
  elif [ -n "$fixture_filter" ]; then
    gated_out+=("biblatex-ua2 (biber or latexmk missing)")
  fi
fi

echo
if [ "${#skipped[@]}" -gt 0 ]; then
  echo "GATES NOT RUN on this machine:"
  printf '  - %s\n' "${skipped[@]}"
  echo
fi

# A gate that is unavailable and a group that was never selected are different
# facts, and under a filter they would otherwise reach the reader as the same
# blank space (issue #367). This names the groups that were asked for and then
# checked nothing.
if [ "${#gated_out[@]}" -gt 0 ]; then
  echo "SELECTED BUT NOT RUN — nothing was checked for:"
  printf '  - %s\n' "${gated_out[@]}"
  echo
fi

# Every group the filter selected was gated out, so not one assertion was made.
# "All passed" would be true and useless -- it is the same sentence a run that
# checked twelve groups prints. This is the pattern-matched-nothing failure in
# another costume, so it fails the same way. Unreachable without a filter, so
# `make check` and the CI job are unaffected.
if [ "${#gated_out[@]}" -gt 0 ] && [ "${#gated_out[@]}" -eq "${#selected[@]}" ]; then
  echo "NO TAGGING FIXTURE RAN$scope_note"
  echo "  Every selected group needs a tool this machine does not have."
  echo "Reports: $reports"
  exit 1
fi

if [ "$fail" -eq 0 ]; then
  if [ "$update" -eq 1 ]; then
    echo "BASELINES UPDATED — review the diff before committing.$scope_note"
  else
    echo "ALL TAGGING FIXTURES PASSED$scope_note"
  fi
else
  echo "TAGGING FIXTURES FAILED$scope_note"
fi
echo "Reports: $reports"
exit "$fail"
