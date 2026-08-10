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
#     page boundary (issue #171, via page-break-check.awk).
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
set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../.." && pwd)"
cd "$here"
# $here joins TEXINPUTS so a zero-stretch control wrapper resolves the fixture
# it \inputs by search path and not only by the working directory it inherits.
export TEXINPUTS="$here:$root:${TEXINPUTS:-}"
control_dir="$(mktemp -d "${TMPDIR:-/tmp}/careerdossier-layout-control.XXXXXX")"
trap 'rm -rf "$control_dir"' EXIT
fail=0

for tex in *.tex; do
  base="${tex%.tex}"
  echo "== $tex =="

  if ! lualatex -halt-on-error -interaction=nonstopmode "$tex" > "$base.stdout" 2>&1; then
    echo "  COMPILE FAILED (see $base.log)"; fail=1; continue
  fi
  if ! lualatex -halt-on-error -interaction=nonstopmode "$tex" >> "$base.stdout" 2>&1; then
    echo "  RERUN FAILED (see $base.log)"; fail=1; continue
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
    # The control wrapper is built outside this directory: the fixture loop
    # globbed *.tex before its first iteration, so a wrapper written here
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
  case "$base" in
    *-a4-*)
      if ! command -v pdfinfo >/dev/null 2>&1; then
        echo "  pdfinfo absent: cannot verify A4 media box"; fail=1
      elif ! pdfinfo -f 1 -l 1 "$base.pdf" | grep -Eq '^Page( +[0-9]+)? size:.*\(A4\)$'; then
        echo "  WRONG PAPER SIZE: expected A4"
        pdfinfo -f 1 -l 1 "$base.pdf" | grep -E '^Page( +[0-9]+)? size:' | sed 's/^/    /'
        fail=1
      else
        echo "  A4 media box confirmed"
      fi
      ;;
    *)
      if ! command -v pdfinfo >/dev/null 2>&1; then
        echo "  pdfinfo absent: cannot verify default Letter media box"; fail=1
      elif ! pdfinfo -f 1 -l 1 "$base.pdf" | grep -Eq '^Page( +[0-9]+)? size:.*\(letter\)$'; then
        echo "  WRONG DEFAULT PAPER SIZE: expected Letter"
        pdfinfo -f 1 -l 1 "$base.pdf" | grep -E '^Page( +[0-9]+)? size:' | sed 's/^/    /'
        fail=1
      else
        echo "  default Letter media box confirmed"
      fi
      ;;
  esac

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
      page_text="$(pdftotext -enc UTF-8 -f "$n" -l "$n" "$base.pdf" - | sed '/^\f/d')"

      # Folio. Absent on every page under `screen`; under `print` absent from a
      # one-page document and present on every page otherwise. The `screen`
      # assertion is not vacuous: the same fixture under `print` would emit
      # `Page N of M` on each of its pages.
      if [ "$medium_screen" -eq 1 ]; then
        if printf '%s\n' "$page_text" | grep -Eq 'Page [0-9]+ of [0-9]+'; then
          echo "  UNEXPECTED SCREEN FOLIO on page $n"; furniture_fail=1
        fi
      elif [ "$pages" -eq 1 ]; then
        if printf '%s\n' "$page_text" | grep -Fq "Page 1 of 1"; then
          echo "  UNEXPECTED SINGLE-PAGE FOLIO"; furniture_fail=1
        fi
      elif ! printf '%s\n' "$page_text" | grep -Fq "Page $n of $pages"; then
        echo "  MISSING FOLIO: Page $n of $pages"; furniture_fail=1
      fi

      # Running header, from page two onwards.
      if [ "$pages" -gt 1 ] && [ "$n" -gt 1 ]; then
        if [ "$medium_screen" -eq 1 ]; then
          if printf '%s\n' "$page_text" | grep -Fq "$furniture_label"; then
            echo "  UNEXPECTED SCREEN RUNNING HEADER on page $n: $furniture_label"
            furniture_fail=1
          fi
        elif ! printf '%s\n' "$page_text" | grep -Fq "$furniture_label"; then
          echo "  MISSING RUNNING HEADER on page $n: $furniture_label"
          furniture_fail=1
        fi
      fi
      if [ "$pages" -gt 1 ] && [ "$n" -eq 1 ]; then
        label_count="$(printf '%s\n' "$page_text" | grep -Fc "$furniture_label" || true)"
        if [ "$label_count" -ne "$page_one_label_count" ]; then
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
        contact_text="$(pdftotext -layout -enc UTF-8 "$base.pdf" - | tr -d '\f')"
        if printf '%s\n' "$contact_text" \
            | grep -Eq '^[[:space:]]*\||\|[[:space:]]*$'; then
          echo "  ORPHAN CONTACT SEPARATOR"; fail=1
        else
          echo "  wrapped contact lines have no orphan separators"
        fi
        contact_item_fail=0
        while IFS= read -r item; do
          if ! printf '%s\n' "$contact_text" | grep -Fq "$item"; then
            echo "  SPLIT CONTACT ITEM: $item"; fail=1; contact_item_fail=1
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
          items="$(pdftotext -enc UTF-8 -f "$n" -l "$n" "$base.pdf" - \
                   | sed '/^\f/d' | grep -c "$item_pattern" || true)"
          if [ "$items" -eq 1 ]; then
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
          page_a=0; page_b=0
          for (( n = 1; n <= pages; n++ )); do
            page_text="$(pdftotext -enc UTF-8 -f "$n" -l "$n" "$base.pdf" - \
                         | sed '/^\f/d')"
            printf '%s\n' "$page_text" | grep -Fq "$a" && page_a="$n"
            printf '%s\n' "$page_text" | grep -Fq "$b" && page_b="$n"
          done
          if [ "$page_a" -eq 0 ] || [ "$page_b" -eq 0 ]; then
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
    sections="$(sed -n 's/.*\\CDossierSection{\([^}]*\)}.*/\1/p' "$tex")"
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
            if printf '%s\n' "$cw_seen" | grep -qx "$cw_declared"; then
              echo "  negative control fired: $cw_declared with the penalties permitted"
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
done

echo; [ "$fail" -eq 0 ] && echo "ALL LAYOUT FIXTURES PASSED" || echo "LAYOUT FIXTURES FAILED"
exit "$fail"
