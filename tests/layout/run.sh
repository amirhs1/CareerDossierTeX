#!/usr/bin/env bash
# run.sh — CareerDossierTeX layout-stress runner (Phase 1)
#
# Compiles each layout fixture with LuaLaTeX and asserts the page-level
# properties that a document class must keep under stress:
#
#   - it compiles with exit 0;
#   - it produces no overfull boxes (long URLs break; long headings wrap);
#   - every one-page document suppresses page furniture, while every multi-page
#     document emits a folio throughout and a running header after page one;
#   - a fixture named *two-page* actually spans at least two pages;
#   - no *two-page* fixture splits a hyphenated word across a page break, and
#     no letter or statement fixture strands a single line of a paragraph at a
#     page boundary (issue #171, via page-break-check.awk);
#   - no page a policy governs falls below `$page_fill_min` of its goal, read
#     from `\tracingpages` output via page-fill.awk (issue #334). Everything
#     above asserts only that material stays *together*, and all of it passes on
#     a half-empty page. `make review-pagefill` is the same measurement as a
#     full report.
#
# A fixture carrying
#
#   % PAGEFILLFLOOR: <pct>
#
# declares an accepted fill below the global floor, and the runner fails when
# that declaration is no longer needed. See the page-fill block below.
#
# A fixture carrying
#
#   % STRETCHCONTROL: <pt> pt
#
# additionally declares that its clean setting is bought by
# \CDossierEmergencyStretch, and states the deficit it sets with that token
# zeroed. The runner rebuilds it with the token at 0pt and requires the
# overfull box to appear: for such a fixture, "no overfull boxes" above is the
# assertion, and this is the proof that the assertion is still testing the
# token rather than passing for some unrelated reason (issue #310).
#
# Final visual correctness (spacing, balance, typographic detail) remains a
# human review of the rendered PDF; this runner guards the properties a machine
# can check reliably without freezing an unsettled design.
#
# Requirements: lualatex, pdftotext (poppler) for the page-number check, and
# pdfinfo (poppler) for A4 media-box verification.
# Run from anywhere; the repository root is placed on TEXINPUTS.
#
# Usage:
#   ./run.sh                    every fixture — the full suite, and what CI runs
#   ./run.sh <pattern>          only the fixtures matching <pattern>
#   ./run.sh --list [<pattern>] print the selection and compile nothing
#
# or, through the Makefile:  make layout FIXTURE=<pattern>
set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../.." && pwd)"
cd "$here" || exit 1

# Extracted-text guards that answer "could not check" apart from "absent"
# (issue #398). Sourced unconditionally: every furniture, contact, and
# keep-together assertion below goes through it, fanned out or not.
# shellcheck source=tests/lib/text.sh
. "$root/tests/lib/text.sh"

# Fixture selection (issue #359).
#
# With no pattern every fixture runs and nothing about this suite has changed;
# that is the invocation CI makes and the one `make check` makes. A pattern
# selects a subset, so a development loop can re-run the one fixture that failed
# instead of paying for the fifty-odd compiles ahead of it.
#
# The pattern is a shell glob matched anywhere in the basename, so `two-page`
# behaves as a substring search while `resume-*` anchors at the start. It is
# left unquoted in the `case` below for exactly that reason.
#
# A pattern that selects nothing exits nonzero rather than reporting a clean
# run. Every assertion this suite makes is made per fixture, so a run with no
# fixtures passes all of them, and "0 fixtures, all passed" is indistinguishable
# from a suite that actually checked something.
#
# Fixture-level concurrency (issue #390) is opt-in through `--jobs N`, which
# `make layout JOBS=N` passes through. With no `--jobs`, or `--jobs 1`, this
# runner takes the serial path below and is the suite it has always been: the
# same fixtures, in the same order, with byte-identical output.
fixture_filter=""
list_only=0
list_units_only=0
jobs=1
while [ "$#" -gt 0 ]; do
  case "$1" in
    --list)   list_only=1; shift ;;
    # The units the drivers would dispatch. Here that is exactly `--list`, since
    # every unit is one fixture; tests/lint/run-fixture-filter.sh asserts it.
    --list-units) list_units_only=1; shift ;;
    --jobs)
      [ "$#" -ge 2 ] || { echo "--jobs needs a value" >&2; exit 2; }
      jobs="$2"; shift 2
      ;;
    --jobs=*) jobs="${1#--jobs=}"; shift ;;
    -*)       echo "unknown option: $1" >&2; exit 2 ;;
    *)        fixture_filter="$1"; shift ;;
  esac
done

case "$jobs" in
  ''|*[!0-9]*) echo "--jobs takes a positive integer, got: $jobs" >&2; exit 2 ;;
esac
[ "$jobs" -ge 1 ] || { echo "--jobs takes a positive integer" >&2; exit 2; }

fixtures=()
total=0
for tex in *.tex; do
  total=$(( total + 1 ))
  if [ -z "$fixture_filter" ]; then
    fixtures+=("$tex")
  else
    case "${tex%.tex}" in
      *$fixture_filter*) fixtures+=("$tex") ;;
    esac
  fi
done

if [ "${#fixtures[@]}" -eq 0 ]; then
  echo "NO FIXTURE MATCHES '$fixture_filter' (of $total in $here)."
  echo "  ./run.sh --list  prints every available fixture name."
  exit 1
fi

if [ "$list_only" -eq 1 ] || [ "$list_units_only" -eq 1 ]; then
  # Identical lists on purpose: every unit this runner dispatches is one
  # fixture, so `--list-units` differing from `--list` would itself be the bug
  # the lint's dispatch check exists to catch.
  for tex in "${fixtures[@]}"; do echo "${tex%.tex}"; done
  exit 0
fi

# Appended to the closing verdict so a filtered run can never be read as a full
# one. Empty for a full run, which keeps that line byte-identical to before.
scope_note=""
if [ -n "$fixture_filter" ]; then
  scope_note=" (filter '$fixture_filter': ${#fixtures[@]} of $total fixtures — NOT a full run)"
  echo "filter '$fixture_filter': ${#fixtures[@]} of $total fixtures selected"
  echo
fi

# $here joins TEXINPUTS so a zero-stretch control wrapper resolves the fixture
# it \inputs by search path and not only by the working directory it inherits.
export TEXINPUTS="$here:$root:${TEXINPUTS:-}"
control_dir="$(mktemp -d "${TMPDIR:-/tmp}/careerdossier-layout-control.XXXXXX")"
trap 'rm -rf "$control_dir"' EXIT
fail=0

# Minimum page fill, as a percentage of `\pagegoal`, for every page the check
# governs — see the page-fill block below for which pages those are.
#
# 90 is a ratchet, not a fill policy. "How full should a page be" is a design
# question; #333 closed without setting a value, and #351 — which owned the one
# route that would have lifted the outlier below — built it, measured it, and
# declined it. So the question is still unanswered, and the outlier is accepted
# rather than pending. This asks the narrower question the corpus answers: may
# a page get worse than anything the project has deliberately accepted? Measured
# across the 25 governed pages, one sits at 86.9% and every other at 92.9% or
# above, so 90 runs through the gap between the single accepted outlier and the
# rest of the corpus.
#
# It is a real guard rather than a formality. Measured at `8212a0f`, the commit
# before #332, `resume-two-page` filled 80.6% of its goal and left a 140.04pt
# hole — the defect that produced #332, #333, and this check — and 90 fails it.
#
# A fixture whose own accepted state sits below this declares its own floor; see
# `% PAGEFILLFLOOR:` below. Setting `CDOSSIER_PAGE_FILL_MIN=` empty measures and
# reports without asserting, which is how a candidate value is explored.
page_fill_min="${CDOSSIER_PAGE_FILL_MIN-90}"

# One fixture, start to finish (issue #390).
#
# `local fail` shadows the global deliberately. Every assertion below already
# said `fail=1`, and rewriting eighteen of them to accumulate into a new name
# would be eighteen chances to miss one silently — a missed site reports a clean
# fixture, which is the failure this repository keeps producing. Shadowing keeps
# each site as it was and moves the accumulation to the one place that changed:
# the return below, which is the only channel out of a worker subshell.
#
# The two former `continue`s are `return 1`, for the same reason.
layout_fixture() {
  local tex="$1"
  local fail=0
  local base="${tex%.tex}"
  # Guard state, kept local for the same reason `fail` is: a fan-out worker is
  # a subshell, but the serial path runs every fixture in one shell and a stale
  # value carried between them would be read as a verdict.
  local state=0 paper_re paper_label paper_wrong paper_info keep_unchecked=0
  echo "== $tex =="

  # `\tracingpages=1` goes on the command line rather than into a rebuild of
  # its own. It changes nothing but the log — the PDF is byte-identical — and
  # this way the page-fill measurement below reads the same run the rest of the
  # assertions are made against, instead of a second compile that has to be
  # argued to be equivalent. `-jobname` keeps the artifact names the fixture
  # would have produced on its own. The space after `1` terminates the number
  # scan before `\input`, which is an expandable macro in LaTeX and would
  # otherwise be expanded while TeX looked for another digit.
  if ! lualatex -halt-on-error -interaction=nonstopmode -jobname="$base" \
       "\\tracingpages=1 \\input{$tex}" > "$base.stdout" 2>&1; then
    echo "  COMPILE FAILED (see $base.log)"; return 1
  fi
  if ! lualatex -halt-on-error -interaction=nonstopmode -jobname="$base" \
       "\\tracingpages=1 \\input{$tex}" >> "$base.stdout" 2>&1; then
    echo "  RERUN FAILED (see $base.log)"; return 1
  fi

  # No overfull boxes.
  overfull="$(grep -cE 'Overfull \\hbox' "$base.log" || true)"
  if [ "$overfull" -ne 0 ]; then
    echo "  OVERFULL BOXES: $overfull"
    grep -E 'Overfull \\hbox' "$base.log" | sed 's/^/    /' | head -5; fail=1
  else
    echo "  no overfull boxes"
  fi

  # Negative control for the two fixtures that exist to keep
  # \CDossierEmergencyStretch honest (issues #272, #310). Rebuilt with the
  # token zeroed, each must go overfull; a fixture whose text drifted far
  # enough to set clean either way would otherwise keep passing the check
  # above while asserting nothing. The declared deficit is reported next to
  # the measured one rather than compared, because the exact figure moves with
  # the font version and the engine, while its presence does not.
  declared="$(sed -n 's/^% STRETCHCONTROL:[[:space:]]*//p' "$tex" | head -1)"
  if [ -n "$declared" ]; then
    # The control wrapper is built outside this directory: the fixture list was
    # globbed out of *.tex before the loop started, so a wrapper written here
    # would escape this run and then be compiled as a fixture by the next one.
    # \AddToHook, unlike \AtBeginDocument, is a format-level command and may
    # precede \documentclass, which is what lets the wrapper reach into a
    # fixture that carries its own class line.
    control="$control_dir/$base-zero-stretch"
    {
      printf '\\AddToHook{begindocument/before}'
      printf '{\\setlength{\\emergencystretch}{0pt}}\n'
      printf '\\input{%s}\n' "$tex"
    } > "$control.tex"
    if ! lualatex -halt-on-error -interaction=nonstopmode \
         -output-directory="$control_dir" "$control.tex" \
         > "$control.stdout" 2>&1; then
      echo "  ZERO-STRETCH CONTROL FAILED TO COMPILE (see $control.log)"; fail=1
    else
      measured="$(grep -oE 'Overfull \\hbox \([0-9.]+pt' "$control.log" \
                  | sed 's/.*(//' | head -1)"
      if [ -n "$measured" ]; then
        echo "  negative control fired: ${measured} over with the token zeroed"
        echo "    (fixture declares $declared)"
      else
        echo "  NEGATIVE CONTROL DID NOT FIRE: with \\CDossierEmergencyStretch"
        echo "    zeroed this fixture still sets clean, so its \"no overfull"
        echo "    boxes\" result is no longer evidence that the token reaches"
        echo "    the page. Restore the stress rather than dropping the check."
        echo "    Check $control.log for font-loading errors first: a run that"
        echo "    typeset nothing reports no overfull box either, and that"
        echo "    looks identical to a fixture whose text drifted."
        fail=1
      fi
    fi
  fi

  # Page count from the "Output written ... (N page[s])" line.
  pages="$(grep -oE 'Output written on .*\(([0-9]+) page' "$base.log" \
           | grep -oE '\(([0-9]+) page' | grep -oE '[0-9]+' | tail -1)"
  pages="${pages:-0}"
  echo "  pages: $pages"

  # Every *-a4-* wrapper must produce an actual ISO A4 media box. This catches
  # a class accepting the public option but silently retaining Letter paper.
  #
  # pdfinfo's output is captured before it is matched (issue #398). Piped
  # straight into `grep -Eq`, grep's early exit hands pdfinfo a SIGPIPE and
  # `pipefail` turns a match into a non-zero pipeline — reported here as the
  # wrong paper size, about a document with the right one.
  case "$base" in
    *-a4-*)
      paper_re='^Page( +[0-9]+)? size:.*\(A4\)$'
      paper_label='A4'; paper_wrong='WRONG PAPER SIZE: expected A4'
      ;;
    *)
      paper_re='^Page( +[0-9]+)? size:.*\(letter\)$'
      paper_label='default Letter'
      paper_wrong='WRONG DEFAULT PAPER SIZE: expected Letter'
      ;;
  esac
  if ! command -v pdfinfo >/dev/null 2>&1; then
    echo "  pdfinfo absent: cannot verify $paper_label media box"; fail=1
  else
    paper_info="$(pdfinfo -f 1 -l 1 "$base.pdf" 2>/dev/null)" \
      || paper_info="$CDTEXT_UNAVAILABLE"
    text_matches "$paper_info" "$paper_re"
    case "$?" in
      0) echo "  $paper_label media box confirmed" ;;
      1)
        echo "  $paper_wrong"
        printf '%s\n' "$paper_info" | grep -E '^Page( +[0-9]+)? size:' | sed 's/^/    /'
        fail=1
        ;;
      *)
        echo "  UNCHECKABLE MEDIA BOX: pdfinfo produced nothing readable for"
        echo "    $base.pdf, so the $paper_label assertion was never made."
        fail=1
        ;;
    esac
  fi

  # Under the default `medium=print`, shared page furniture is suppressed
  # entirely for a one-page document, and a multi-page document carries
  # `Page N of M` throughout and an identity-derived running header from page
  # two onwards. Under `medium=screen` (issue #184, fixtures named
  # `*-screen-*`) neither is emitted on any page. Check extracted text rather
  # than exact coordinates so the test guards behavior without freezing layout.
  if command -v pdftotext >/dev/null 2>&1; then
    case "$base" in
      *-screen-*) medium_screen=1 ;;
      *)          medium_screen=0 ;;
    esac

    furniture_label=""
    case "$base" in
      resume-*)           furniture_label="Résumé" ;;
      cv-*)               furniture_label="Curriculum Vitae" ;;
      letter-*)           furniture_label="Cover Letter" ;;
      statement-interest-long-fields-two-page)
        furniture_label="Statement of Interest"
        ;;
      statement-*)        furniture_label="Computational Reliability" ;;
    esac

    furniture_fail=0
    page_one_label_count=0
    if [ "$base" = "statement-interest-long-fields-two-page" ]; then
      # The display title and running title are intentionally identical. Page
      # one must contain the display title once, not a second copy in a header.
      page_one_label_count=1
    fi
    for (( n = 1; n <= pages; n++ )); do
      page_text="$(text_page "$base.pdf" "$n")"

      # Folio. Absent on every page under `screen`; under `print` absent from a
      # one-page document and present on every page otherwise. The `screen`
      # assertion is not vacuous: the same fixture under `print` would emit
      # `Page N of M` on each of its pages.
      #
      # Each of the three branches below reads the predicate's status three
      # ways (issue #398). The `screen` branches are why: there a check that
      # could not run used to be indistinguishable from a clean page, so the
      # fixture passed having asserted nothing. `state 0/1` is the verdict;
      # anything else is the absence of one, and fails on its own terms.
      if [ "$medium_screen" -eq 1 ]; then
        text_matches "$page_text" 'Page [0-9]+ of [0-9]+'; state=$?
        if [ "$state" -eq 0 ]; then
          echo "  UNEXPECTED SCREEN FOLIO on page $n"; furniture_fail=1
        elif [ "$state" -ne 1 ]; then
          echo "  UNCHECKABLE SCREEN FOLIO on page $n: no page text"; furniture_fail=1
        fi
      elif [ "$pages" -eq 1 ]; then
        text_contains "$page_text" "Page 1 of 1"; state=$?
        if [ "$state" -eq 0 ]; then
          echo "  UNEXPECTED SINGLE-PAGE FOLIO"; furniture_fail=1
        elif [ "$state" -ne 1 ]; then
          echo "  UNCHECKABLE SINGLE-PAGE FOLIO: no page text"; furniture_fail=1
        fi
      else
        text_contains "$page_text" "Page $n of $pages"; state=$?
        if [ "$state" -eq 1 ]; then
          echo "  MISSING FOLIO: Page $n of $pages"; furniture_fail=1
        elif [ "$state" -ne 0 ]; then
          echo "  UNCHECKABLE FOLIO on page $n: no page text"; furniture_fail=1
        fi
      fi

      # Running header, from page two onwards.
      if [ "$pages" -gt 1 ] && [ "$n" -gt 1 ]; then
        text_contains "$page_text" "$furniture_label"; state=$?
        if [ "$medium_screen" -eq 1 ]; then
          if [ "$state" -eq 0 ]; then
            echo "  UNEXPECTED SCREEN RUNNING HEADER on page $n: $furniture_label"
            furniture_fail=1
          elif [ "$state" -ne 1 ]; then
            echo "  UNCHECKABLE SCREEN RUNNING HEADER on page $n: no page text"
            echo "    or no label for $base; nothing was asserted."
            furniture_fail=1
          fi
        elif [ "$state" -eq 1 ]; then
          echo "  MISSING RUNNING HEADER on page $n: $furniture_label"
          furniture_fail=1
        elif [ "$state" -ne 0 ]; then
          echo "  UNCHECKABLE RUNNING HEADER on page $n: no page text or no"
          echo "    label for $base; nothing was asserted."
          furniture_fail=1
        fi
      fi
      if [ "$pages" -gt 1 ] && [ "$n" -eq 1 ]; then
        # Counted with the third state, because 0 is this check's *passing*
        # value: `grep -Fc` over text that was never extracted also answers 0,
        # so the old spelling reported a clean page one for a page it had not
        # read (issue #398).
        label_count="$(text_count_lines "$page_text" "$furniture_label")"
        state=$?
        if [ "$state" -ne 0 ]; then
          echo "  UNCHECKABLE PAGE-ONE RUNNING LABEL count: no page text, or no"
          echo "    furniture label for $base; nothing was asserted."
          furniture_fail=1
        elif [ "$label_count" -ne "$page_one_label_count" ]; then
          echo "  UNEXPECTED PAGE-ONE RUNNING LABEL count: $label_count"
          furniture_fail=1
        fi
      fi
    done
    if [ "$furniture_fail" -ne 0 ]; then
      fail=1
    elif [ "$medium_screen" -eq 1 ]; then
      echo "  medium=screen: no folio or running header on any page"
    elif [ "$pages" -eq 1 ]; then
      echo "  single-page furniture suppressed"
    else
      echo "  multi-page folios and running headers present"
    fi

    case "$base" in
      resume-contact-wrap-*)
        contact_text="$(text_extract "$base.pdf" -layout)"
        text_matches "$contact_text" '^[[:space:]]*\||\|[[:space:]]*$'; state=$?
        if [ "$state" -eq 0 ]; then
          echo "  ORPHAN CONTACT SEPARATOR"; fail=1
        elif [ "$state" -ne 1 ]; then
          echo "  UNCHECKABLE CONTACT SEPARATORS: no -layout text for $base"; fail=1
        else
          echo "  wrapped contact lines have no orphan separators"
        fi
        contact_item_fail=0
        while IFS= read -r item; do
          text_contains "$contact_text" "$item"; state=$?
          if [ "$state" -eq 1 ]; then
            echo "  SPLIT CONTACT ITEM: $item"; fail=1; contact_item_fail=1
          elif [ "$state" -ne 0 ]; then
            echo "  UNCHECKABLE CONTACT ITEM: $item"; fail=1; contact_item_fail=1
          fi
        done <<'EOF'
alexandria.montgomery.fitzgerald@a-very-long-department.example.org
+1 416 555 0142
Greater Toronto Regional Office, Ontario, Canada
example.org/alexandria-montgomery-fitzgerald/portfolio
linkedin.com/in/alexandria-montgomery-fitzgerald
github.com/alexandria-montgomery-fitzgerald
scholar.google.com/citations?user=AlexandriaMontgomery
ORCID: 0000-0002-1825-0097
EOF
        if [ "$contact_item_fail" -eq 0 ]; then
          echo "  every contact item remains on one visual line"
        fi
        ;;
    esac

    # Keep-together page-break policy (issue #145). These fixtures place
    # headings and bullet lists across a page boundary on purpose.
    case "$base" in
      *keeptogether*)
        if [ "$pages" -lt 2 ]; then
          echo "  EXPECTED a page break to exercise, got $pages page(s)"
          fail=1
        fi

        keep_fail=0

        # No list may be split leaving exactly one item on a page. The
        # *-orphan* fixtures mark the list under test so its items can be
        # counted apart from the filler bullets sharing the same page; the
        # remaining fixtures hold a single list, so every bullet belongs to it.
        case "$base" in
          *-orphan*) item_pattern='^• Probe' ;;
          *)         item_pattern='^•' ;;
        esac
        for (( n = 1; n <= pages; n++ )); do
          # `-eq 1` is the failing case, so every other count passes — including
          # the 0 that an unextracted page produces. Counted with the third
          # state so "no page text" cannot report "no orphaned bullet" (#398).
          page_text="$(text_page "$base.pdf" "$n")"
          items="$(text_count_matches "$page_text" "$item_pattern")"
          state=$?
          if [ "$state" -ne 0 ]; then
            echo "  UNCHECKABLE ORPHANED BULLET: page $n of $base yielded no"
            echo "    text, so its item count was never taken."
            keep_fail=1
          elif [ "$items" -eq 1 ]; then
            echo "  ORPHANED BULLET: page $n carries exactly one item of the split list"
            keep_fail=1
          fi
        done

        # A heading must not be separated from the material it introduces.
        # Each fixture declares its own requirements as
        #   % KEEPTOGETHER: <text a> ||| <text b>
        # meaning both snippets must land on the same page. This covers a
        # section heading stranded from its first entry, an entry heading
        # stranded from its body, and an entry heading whose own two lines
        # would otherwise split across the break.
        while IFS= read -r directive; do
          [ -n "$directive" ] || continue
          a="${directive%%|||*}"; b="${directive#*|||}"
          a="$(printf '%s' "$a" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')"
          b="$(printf '%s' "$b" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')"
          page_a=0; page_b=0; keep_unchecked=0
          for (( n = 1; n <= pages; n++ )); do
            page_text="$(text_page "$base.pdf" "$n")"
            text_contains "$page_text" "$a"; state=$?
            [ "$state" -eq 0 ] && page_a="$n"
            [ "$state" -gt 1 ] && keep_unchecked=1
            text_contains "$page_text" "$b"; state=$?
            [ "$state" -eq 0 ] && page_b="$n"
            [ "$state" -gt 1 ] && keep_unchecked=1
          done
          if [ "$keep_unchecked" -ne 0 ]; then
            # Distinguished from NOT FOUND deliberately: a page whose text
            # could not be extracted cannot support either verdict, and
            # reporting it as "not found" is a claim about a document that was
            # never read (issue #398).
            echo "  UNCHECKABLE KEEPTOGETHER: a page of $base yielded no text,"
            echo "    so '$a' / '$b' were never located."
            keep_fail=1
          elif [ "$page_a" -eq 0 ] || [ "$page_b" -eq 0 ]; then
            echo "  KEEPTOGETHER TEXT NOT FOUND: '$a' / '$b'"; keep_fail=1
          elif [ "$page_a" -ne "$page_b" ]; then
            echo "  SPLIT ACROSS PAGES ($page_a vs $page_b): '$a' / '$b'"
            keep_fail=1
          fi
        done < <(sed -n 's/^% KEEPTOGETHER:[[:space:]]*//p' "$tex")

        if [ "$keep_fail" -ne 0 ]; then
          fail=1
        else
          echo "  no stranded heading and no orphaned bullet at any break"
        fi
        ;;
    esac

    # Issue #333: no page may end with a section heading. The penalty that used
    # to forbid the break after the section rule is gone, replaced by a bound
    # applied before the heading, so this is the failure mode that bound exists
    # to prevent and it needs asserting rather than eyeballing.
    #
    # This runs for every fixture, not only the *keeptogether* ones, and needs no
    # per-fixture bookkeeping: the section titles are read out of the fixture's
    # own source, so a fixture that gains a section is covered the moment it does.
    # The KEEPTOGETHER directives cannot do this job — they assert the particular
    # pairs a fixture happens to declare, and a heading stranded at the foot of a
    # page is a property of every page boundary in every fixture.
    #
    # Issue #337: \CDossierSubsection is collected by the same pattern. It is the
    # same failure — a heading alone at the foot of a page, introducing nothing —
    # and \CDossierSubsectionNeedLines is the bound that prevents it, so it needs
    # the same assertion rather than a second one. The `sub' alternative is
    # optional in the pattern rather than matched separately so that the two
    # spellings cannot drift apart here.
    sections="$(sed -n 's/.*\\CDossier\(Sub\)\{0,1\}section{\([^}]*\)}.*/\2/p' "$tex")"
    if [ -n "$sections" ] && [ "$pages" -gt 1 ]; then
      strand_fail=0
      for (( n = 1; n < pages; n++ )); do
        last_line="$(pdftotext -enc UTF-8 -f "$n" -l "$n" "$base.pdf" - \
                     | sed '/^\f/d' | grep -v '^[[:space:]]*$' \
                     | grep -Ev 'Page [0-9]+ of [0-9]+' | tail -1)"
        while IFS= read -r sec; do
          [ -n "$sec" ] || continue
          if [ "$last_line" = "$sec" ]; then
            echo "  STRANDED SECTION HEADING: page $n ends with '$sec'"
            strand_fail=1
          fi
        done <<EOF
$sections
EOF
      done
      if [ "$strand_fail" -ne 0 ]; then
        fail=1
      else
        echo "  no page ends with a section heading"
      fi
    fi
  else
    echo "  (pdftotext absent: skipped folio check)"
  fi

  # Page fill — the other half of the page-break policy (issue #334).
  #
  # Everything above asserts that material stays *together*. Not one of those
  # assertions can fail on a page that is half empty, and for documents whose
  # entire constraint is a page limit that is the more important half. It sits
  # here, beside the keeps, so the two halves are read and maintained together.
  #
  # The measurement comes from `\tracingpages` in the log rather than from the
  # PDF, so it needs no poppler and runs wherever this suite runs. page-fill.awk
  # documents the trace and the two non-obvious things about reading it.
  #
  # Two page kinds are skipped, and skipping them is not a weakening:
  #   - the last page, because a short last page is normal and says nothing;
  #   - an `eject` page, one the fixture source ended itself with `\newpage`.
  #     Five committed fixtures do that, and their page-one fill runs from 26%
  #     to 54% purely because their source says so. A threshold that counted
  #     them would fail five fixtures for behaving exactly as written.
  fill_records="$(awk -f "$here/page-fill.awk" "$base.log")"
  # guard-ok: compared against $pages, derived independently from the log, so a
  # parse that finds nothing reports 0 against a non-zero page count and fails.
  fill_pages="$(printf '%s\n' "$fill_records" | grep -c '.' || true)"
  if [ "$fill_pages" -ne "$pages" ]; then
    echo "  PAGE-FILL PARSE MISMATCH: $fill_pages record(s) for $pages page(s)."
    echo "    page-fill.awk identifies a page by TeX's own shipout marker, and"
    echo "    that rule no longer matches this log. Fix the parser rather than"
    echo "    relaxing the check: a parser that finds no page reports no hole,"
    echo "    which looks identical to a corpus that has none."
    fail=1
  else
    echo "  page fill: $(printf '%s\n' "$fill_records" | awk -F'\t' '
      { tag = $6; if ($10 == 1) tag = tag ",last"
        printf "%s%s %.1f%% (%s)", (NR > 1 ? ", " : ""), $1, $4, tag }
      END { print "" }')"

    # The enforcement hook. `$page_fill_min` above carries the global floor and
    # the reasoning for its value.
    #
    # A fixture may declare an accepted state below that floor with
    #
    #   % PAGEFILLFLOOR: <pct>
    #
    # the way fixtures already declare STRETCHCONTROL and CLUBWIDOWCONTROL. The
    # exemption then lives in the fixture that owns it, where whoever next
    # changes that family's pagination will see it, rather than inside a global
    # number quietly chosen low enough to accommodate it.
    #
    # A declaration nobody needs any more is a hole in the guard that reports
    # nothing, so it is held to account the same way its neighbours are: when
    # every governed page of a declaring fixture clears the *global* floor, the
    # declaration has expired and the run fails asking for its removal.
    fixture_floor="$(sed -n 's/^% PAGEFILLFLOOR:[[:space:]]*//p' "$tex" | head -1)"
    effective_floor="${fixture_floor:-$page_fill_min}"
    if [ -n "$fixture_floor" ]; then
      echo "  declared page-fill floor: ${fixture_floor}% (global ${page_fill_min:-none})"
    fi

    fill_fail=0
    floor_still_needed=0
    # `goal`, `used`, and `nxt` are positional placeholders, not oversights:
    # `read` fills by position, and the columns this loop does use sit after
    # them, so they cannot be dropped without renumbering the record.
    # shellcheck disable=SC2034
    while IFS="$(printf '\t')" read -r pg goal used pct pen kind nxt atom blank last; do
      [ -n "$pg" ] || continue
      if [ "$last" -eq 1 ] || [ "$kind" = "eject" ]; then continue; fi
      [ -n "$page_fill_min" ] || continue
      if awk -v a="$pct" -v b="$page_fill_min" 'BEGIN { exit !(a < b) }'; then
        floor_still_needed=1
      fi
      if awk -v a="$pct" -v b="$effective_floor" 'BEGIN { exit !(a < b) }'; then
        echo "  PAGE UNDERFILLED: page $pg is ${pct}% of its goal (${blank}pt blank),"
        echo "    below the ${effective_floor}% floor. Break kind '$kind' at penalty $pen."
        if [ "$atom" != "-" ]; then
          echo "    The next candidate was ${atom}pt further on: that is the atom"
          echo "    that did not fit, and the size any fix has to find room for."
        else
          echo "    Nothing was rejected, so the hole is not an atom that did not"
          echo "    fit — a policy rule ended this page early."
        fi
        fill_fail=1
      fi
    done <<EOF
$fill_records
EOF

    if [ -n "$page_fill_min" ] && [ -n "$fixture_floor" ] \
       && [ "$floor_still_needed" -eq 0 ]; then
      echo "  EXPIRED PAGE-FILL FLOOR: this fixture declares ${fixture_floor}%, but"
      echo "    every page it governs now clears the ${page_fill_min}% global floor."
      echo "    Delete the % PAGEFILLFLOOR line rather than leaving it in place: a"
      echo "    declared exemption nobody needs still suppresses the global floor"
      echo "    for this fixture, and suppresses it silently."
      fill_fail=1
    fi

    [ "$fill_fail" -eq 0 ] || fail=1
  fi

  case "$base" in
    *two-page*)
      if [ "$pages" -lt 2 ]; then
        echo "  EXPECTED at least two pages, got $pages"; fail=1
      else
        echo "  spans multiple pages as intended"
      fi

      # Typographic page-break quality (issue #171): no hyphenated word split
      # across a page break, and no single line of a paragraph stranded at a
      # page boundary. Both are decided from per-word coordinates rather than
      # extracted text — see page-break-check.awk for why text-based tests
      # fail here in both directions.
      #
      # The broken-word check applies to every family. The club/widow checks
      # are enabled only for letter and statement, matching the split
      # docs/API.md's page-break policy already draws: résumé and CV are
      # entry-structured and governed by the structural keep-together
      # penalties, and their entry headings and datelines end without
      # sentence punctuation exactly as an unfinished prose line does, so a
      # paragraph-remnant assertion is not meaningful over that content.
      if command -v pdftotext >/dev/null 2>&1; then
        case "$base" in
          letter-*|statement-*) prose=1 ;;
          *)                    prose=0 ;;
        esac

        typo_fail=0
        findings="$(pdftotext -bbox "$base.pdf" - \
          | awk -v furniture="$furniture_label" -v prose="$prose" \
              -f "$here/page-break-check.awk")"
        if [ -n "$findings" ]; then
          while IFS="$(printf '\t')" read -r kind pg text; do
            [ -n "$kind" ] || continue
            case "$kind" in
              BROKEN)
                echo "  HYPHENATED WORD SPLIT ACROSS PAGE BREAK: page $pg ends '$text'"
                ;;
              *)
                echo "  $kind LINE: page $pg: '$text'"
                ;;
            esac
          done <<EOF
$findings
EOF
          typo_fail=1
        fi

        if [ "$typo_fail" -eq 0 ]; then
          if [ "$prose" -eq 1 ]; then
            echo "  no hyphen-split, widow, or club line at page breaks"
          else
            echo "  no hyphen-split at page breaks"
          fi
        else
          fail=1
        fi

        # Negative control for the club/widow check itself (issue #348).
        #
        # A clean result above is evidence only if the check can report a dirty
        # one, and for most of this suite's life it could not: its paragraph
        # boundary threshold sat above the gap `\parskip` actually produces, so
        # it saw each page as one paragraph and never fired. Nothing failed,
        # because the penalties were forbidding the breaks anyway — a detector
        # that cannot detect and a document with nothing to detect print the
        # same thing.
        #
        # A fixture carrying
        #
        #   % CLUBWIDOWCONTROL: <KIND>
        #
        # declares that permitting the break — \clubpenalty and \widowpenalty
        # at 0, which is every value below 10000, since the penalty is a
        # boolean here (#342) — strands a line it names. The runner rebuilds it
        # that way and requires <KIND> to be reported. The shipped classes are
        # untouched: the control sets the parameters in a wrapper.
        #
        # This is what makes the threshold in page-break-check.awk owned rather
        # than merely present. At the old 1.35 the declared CLUB is not
        # reported and this control fails.
        cw_declared="$(sed -n 's/^% CLUBWIDOWCONTROL:[[:space:]]*//p' "$tex" | head -1)"
        if [ -n "$cw_declared" ] && [ "$prose" -eq 1 ]; then
          cwc="$control_dir/$base-club-widow"
          {
            printf '\\AddToHook{begindocument/before}'
            printf '{\\clubpenalty=0 \\widowpenalty=0 }\n'
            printf '\\input{%s}\n' "$tex"
          } > "$cwc.tex"
          if ! lualatex -halt-on-error -interaction=nonstopmode \
               -output-directory="$control_dir" "$cwc.tex" \
               > "$cwc.stdout" 2>&1; then
            echo "  CLUB/WIDOW CONTROL FAILED TO COMPILE (see $cwc.log)"; fail=1
          else
            cw_seen="$(pdftotext -bbox "$cwc.pdf" - \
              | awk -v furniture="$furniture_label" -v prose=1 \
                    -f "$here/page-break-check.awk" | cut -f1 | sort -u)"
            text_contains_line "$cw_seen" "$cw_declared"; state=$?
            if [ "$state" -eq 0 ]; then
              echo "  negative control fired: $cw_declared with the penalties permitted"
            elif [ "$state" -gt 1 ]; then
              echo "  UNCHECKABLE CLUB/WIDOW CONTROL: the control build produced"
              echo "    no comparable result, so its firing was never established."
              fail=1
            else
              echo "  CLUB/WIDOW NEGATIVE CONTROL DID NOT FIRE: this fixture"
              echo "    declares $cw_declared with \\clubpenalty and \\widowpenalty"
              echo "    at 0, and the check reported '${cw_seen:-nothing}'. Its clean"
              echo "    result above is therefore not evidence of anything."
              echo "    Check the paragraph-gap threshold in page-break-check.awk"
              echo "    first: raising it past the gap \\parskip produces makes"
              echo "    every paragraph boundary invisible and every fixture pass."
              fail=1
            fi
          fi
        fi
      else
        echo "  (pdftotext absent: skipped typographic page-break check)"
      fi
      ;;
  esac
  return "$fail"
}

# --------------------------------------------------------------------------
# The two drivers. Same fixtures, same order; the only difference is how many
# are in flight, and — for the parallel one — the accounting assertion that a
# fixture which left no verdict is a failure rather than a smaller denominator.
#
# $control_dir needs no protection from the fan-out. Its cleanup is an EXIT
# trap, and a trap does not fire in a background subshell: measured on both
# bash 5.3 and the macOS /bin/bash 3.2 this suite has to run under, it fires
# once, in the parent, after `wait`. The wrappers written into it are named
# per fixture already, so no two workers share a path there either.

fail=0

if [ "$jobs" -eq 1 ]; then
  for tex in "${fixtures[@]}"; do
    layout_fixture "$tex" || fail=1
  done
else
  # shellcheck source=tests/lib/fanout.sh
  . "$root/tests/lib/fanout.sh"
  scratch="$root/build/fanout/layout"
  rm -rf "$scratch"
  mkdir -p "$scratch" || { echo "cannot create $scratch" >&2; exit 2; }

  fanout_reset
  for tex in "${fixtures[@]}"; do
    fanout_add "${tex%.tex}" "layout_fixture '$tex'" || exit 2
  done

  echo "fixture concurrency: $jobs at a time (the gate is the serial run)"
  # Required before fan-out: several LuaLaTeX processes racing to build a cold
  # luaotfload cache is when it goes wrong, and a nullfont run produces no
  # overfull box, no stranded heading, and no underfull page — it passes every
  # assertion above having typeset nothing.
  fanout_warm_fonts "$scratch" || exit 1
  echo
  fanout_run "$jobs" "$scratch"
  fanout_gather "$scratch"
  fanout_replay "$scratch"
  fanout_account fixtures || fail=1
  for (( i = 0; i < ${#fixtures[@]}; i++ )); do
    case "${fanout_states[$i]}" in
      FAILED*) fail=1 ;;
    esac
  done
fi

echo
[ "$fail" -eq 0 ] && echo "ALL LAYOUT FIXTURES PASSED$scope_note" \
                  || echo "LAYOUT FIXTURES FAILED$scope_note"
exit "$fail"
