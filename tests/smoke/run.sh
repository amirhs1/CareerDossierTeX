#!/usr/bin/env bash
# run.sh — CareerDossierTeX smoke runner (Phase 1)
#
# Compiles each fixture with LuaLaTeX and checks it against an expected outcome:
#
#   pass  — must compile with exit 0 and a clean log (only allowlisted warnings)
#   fail  — must stop with a nonzero exit, and its log must contain the expected
#           diagnostic substring (proving the *intended* error fired, not an
#           unrelated one)
#   fail-once
#         — as `fail', plus a second substring that must appear exactly once.
#           A rejected class option is owned by one module, so it must be
#           reported by one module (issue #232). Proving that needs the whole
#           document processed, so these fixtures run without -halt-on-error:
#           under it TeX stops at the first report and a second one further
#           down the preamble would never reach the log.
#
# This is the supported-build and required-failure gate for the résumé class.
# It complements the layout runner (page stress) and the extraction runner
# (text layer and reading order).
#
# Requirements: lualatex, xelatex, and pdflatex. Run from anywhere; the
# repository root is put on TEXINPUTS so the root classes and packages resolve.
#
# Usage:
#   ./run.sh                    every fixture — the full suite, and what CI runs
#   ./run.sh <pattern>          only the fixtures matching <pattern>
#   ./run.sh --list [<pattern>] print the selection and compile nothing
#
# or, through the Makefile:  make smoke FIXTURE=<pattern>
set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../.." && pwd)"
cd "$here"
export TEXINPUTS="$root:${TEXINPUTS:-}"
fail=0

# Fixture selection (issue #359).
#
# With no pattern every fixture runs and nothing about this suite has changed;
# that is the invocation CI makes and the one `make check' makes. A pattern
# selects a subset, so a development loop can re-run the one fixture that failed
# instead of paying for the hundred-odd compiles ahead of it.
#
# The pattern is a shell glob matched anywhere in the basename, so `bad-medium'
# behaves as a substring search while `letter-*' anchors at the start. It is
# left unquoted in the `case' below for exactly that reason.
#
# A pattern that selects nothing exits nonzero rather than reporting a clean
# run. Every assertion here is made per fixture, so a run with no fixtures
# passes all of them, and that is indistinguishable from a suite that checked
# something.
fixture_filter=""
list_only=0
for arg in "$@"; do
  case "$arg" in
    --list) list_only=1 ;;
    -*)     echo "unknown option: $arg" >&2; exit 2 ;;
    *)      fixture_filter="$arg" ;;
  esac
done

fixture_matches() {
  [ -z "$fixture_filter" ] && return 0
  case "$1" in
    *$fixture_filter*) return 0 ;;
  esac
  return 1
}

# Warnings tolerated in a "pass" build. Kept short and justified; mirrors the
# extraction runner. hyperref/geometry are expected loads; the ...Off ligature
# notices come from fonts without those OpenType tables. The tagpdf math-font
# notice is expected for the focused tagged text fixture, which contains no
# mathematics and intentionally loads neither Unicode-math package.
allow='not available for font|Ligatures=CommonOff|ContextualOff, DiscretionaryOff|Neither unicode-math nor lua-unicode-math|rerun|Reading font info|geometry|hyperref|fancyhdr'

# Fixture expectations:
#
#   "<basename> <pass|fail> [expected log substring]"
#   "<basename> fail-once|<expected substring>|<substring expected exactly once>"
#
# Substrings are matched against the log with whitespace flattened, so they may
# span the log's wrapped lines. The `fail-once' pair is split on the last `|',
# so neither substring may contain one.
cases=(
  "resume-valid pass"
  "resume-12pt pass"
  "resume-sans-body pass"
  "resume-sans-body-tagged pass"
  "resume-section-leading pass"
  "resume-section-rule-spacing pass"
  "resume-section-rule-gap pass"
  "resume-section-rule-baseline pass"
  "resume-section-rule-baseline-10pt pass"
  "resume-section-rule-baseline-12pt pass"
  "resume-itemize-alignment pass"
  "resume-itemize-trailing-glue pass"
  "resume-list-edge-gap pass"
  "resume-list-edge-gap-tagged pass"
  "resume-list-edge-gap-tagged-10pt pass"
  "resume-medium-screen pass"
  "resume-muted-gray pass"
  "resume-muted-both pass"
  "resume-muted-plain pass"
  "resume-muted-italic pass"
  "resume-entrymeta-inline pass"
  "resume-density-option fail|Supported options are 'fontsize', 'margin', 'paper', 'bodyfont', 'medium', 'muted', and 'entrymeta'."
  "resume-missing-name fail|required profile field 'name' is not"
  "resume-bad-fontsize fail-once|Unknown 'fontsize' value '9pt' for careerdossier-resume.|Unknown 'fontsize' value '9pt'"
  "resume-bad-paper fail|Unknown 'paper' value 'legal' for careerdossier-resume."
  "resume-bad-bodyfont fail|Unknown 'bodyfont' value 'decorative' for careerdossier-resume."
  "resume-bad-medium fail|Unknown 'medium' value 'paper' for careerdossier-resume."
  "resume-bad-muted fail|Unknown 'muted' value 'grey' for careerdossier-resume."
  "resume-bad-entrymeta fail|Unknown 'entrymeta' value 'flush' for careerdossier-resume."
  "resume-unknown-option fail|Unknown class option 'format'"
  "resume-unknown-entry-key fail|Unknown CDossierEntry key 'employer'"
  "resume-contact-too-wide fail|is wider than the available contact-line width."
  "resume-shared-profile pass"
  "components-header-stack-doc pass"
  "cv-valid pass"
  "cv-sans-body pass"
  "cv-shared-profile pass"
  "cv-section-leading pass"
  "cv-section-rule-spacing pass"
  "cv-section-rule-gap pass"
  "cv-section-rule-baseline pass"
  "cv-publication-list-tokens pass"
  "cv-itemize-trailing-glue pass"
  "cv-list-edge-gap pass"
  "cv-list-edge-gap-tagged pass"
  "cv-publication-list-edge-gap pass"
  "cv-publication-list-edge-gap-tagged pass"
  "cv-medium-screen pass"
  "cv-entrymeta-inline pass"
  "cv-density-option fail|Supported options are 'fontsize', 'margin', 'paper', 'bodyfont', 'medium', 'muted', and 'entrymeta'."
  "cv-missing-name fail|required profile field 'name' is not"
  "cv-bad-fontsize fail-once|Unknown 'fontsize' value '9pt' for careerdossier-cv.|Unknown 'fontsize' value '9pt'"
  "cv-bad-paper fail|Unknown 'paper' value 'legal' for careerdossier-cv."
  "cv-bad-bodyfont fail|Unknown 'bodyfont' value 'decorative' for careerdossier-cv."
  "cv-bad-medium fail|Unknown 'medium' value 'paper' for careerdossier-cv."
  "cv-bad-muted fail|Unknown 'muted' value 'grey' for careerdossier-cv."
  "cv-bad-entrymeta fail|Unknown 'entrymeta' value 'flush' for careerdossier-cv."
  "cv-unknown-option fail|Unknown class option 'format'"
  "cv-unknown-entry-key fail|Unknown CDossierEntry key 'employer'"
  "cv-publications-valid pass"
  "cv-publication-missing-authors fail|A manual publication is missing its required"
  "cv-publication-missing-title fail|'title' field."
  "cv-publication-outside-list fail|may only be used inside"
  "cv-biblatex-missing-given fail|nonblank 'given' key."
  "cv-biblatex-missing-dependency fail|optional dependency"
  "letter-valid pass"
  "letter-custom-geometry pass"
  "letter-academic-valid pass"
  "letter-industry-10pt pass"
  "letter-industry-11pt pass"
  "letter-industry-12pt pass"
  "letter-academic-10pt pass"
  "letter-academic-11pt pass"
  "letter-academic-12pt pass"
  "letter-sans-body pass"
  "letter-medium-screen pass"
  "letter-bad-family fail|Unknown 'family' value 'committee' for careerdossier-letter."
  "letter-bad-fontsize fail-once|Unknown 'fontsize' value '13pt' for careerdossier-letter.|Unknown 'fontsize' value '13pt'"
  "letter-bad-margin fail-once|Unknown 'margin' value 'wide' for careerdossier-letter.|Unknown 'margin' value 'wide'"
  "letter-bad-paper fail|Unknown 'paper' value 'legal' for careerdossier-letter."
  "letter-bad-bodyfont fail|Unknown 'bodyfont' value 'decorative' for careerdossier-letter."
  "letter-bad-medium fail|Unknown 'medium' value 'paper' for careerdossier-letter."
  "letter-no-subject pass"
  "letter-no-recipient-subject pass"
  "letter-missing-name fail|required profile field 'name' is not"
  "letter-unknown-option fail|Unknown class option 'format'"
  "letter-unknown-meta-key fail|Unknown \CDossierLetterSetup key"
  "statement-research-valid pass"
  "statement-teaching-valid pass"
  "statement-teaching-philosophy-valid pass"
  "statement-diversity-valid pass"
  "statement-artist-valid pass"
  "statement-purpose-valid pass"
  "statement-default-valid pass"
  "statement-interest-valid pass"
  "statement-section-gap pass"
  "statement-section-style pass"
  "statement-name-10pt pass"
  "statement-name-11pt pass"
  "statement-name-12pt pass"
  "statement-general-interest fail|'general-interest'."
  "statement-sans-body pass"
  "statement-medium-screen pass"
  "statement-muted-gray pass"
  "statement-muted-plain pass"
  "statement-muted-italic pass"
  "statement-bad-medium fail|Unknown 'medium' value 'paper' for careerdossier-statement."
  "statement-empty-type fail|The key 'cdossier/statement/type' requires a value"
  "statement-bad-type fail|Unknown statement type 'grant'"
  "statement-bad-paper fail|Unknown 'paper' value 'legal' for careerdossier-statement."
  "statement-bad-fontsize fail-once|Unknown 'fontsize' value '13pt' for careerdossier-statement.|Unknown 'fontsize' value '13pt'"
  "statement-bad-margin fail-once|Unknown 'margin' value 'wide' for careerdossier-statement.|Unknown 'margin' value 'wide'"
  "statement-bad-bodyfont fail|Unknown 'bodyfont' value 'decorative' for careerdossier-statement."
  "statement-unknown-option fail|Unknown class option 'format'"
  "statement-unknown-meta-key fail|Unknown \CDossierStatementSetup key"
  "statement-missing-name fail|required profile field 'name' is not"
  "statement-missing-email fail|required profile field 'email' is not"
  "statement-research-missing-affiliation fail|required profile field 'affiliation'"
  "statement-artist-missing-website fail|required profile field 'website'"
)

# The engine contract is a fixture of this suite like any other — it has its own
# engine-contract.tex — but it is not a `cases' entry, because its expectation
# is one per engine rather than a single pass/fail. It joins the universe here
# so a filter can select it and `--list' can name it.
engine_fixture="engine-contract"
engine_needle="Compile with lualatex, not"

selected_cases=()
engine_selected=0
fixture_matches "$engine_fixture" && engine_selected=1
for entry in "${cases[@]}"; do
  fixture_matches "${entry%% *}" && selected_cases+=("$entry")
done
total=$(( ${#cases[@]} + 1 ))
n_selected=$(( ${#selected_cases[@]} + engine_selected ))

if [ "$n_selected" -eq 0 ]; then
  echo "NO FIXTURE MATCHES '$fixture_filter' (of $total in $here)."
  echo "  ./run.sh --list  prints every available fixture name."
  exit 1
fi

if [ "$list_only" -eq 1 ]; then
  [ "$engine_selected" -eq 1 ] && echo "$engine_fixture"
  # Guarded rather than expanded unconditionally: an empty array expansion is an
  # unbound-variable error under `set -u' in bash 3.2, and a filter matching
  # only the engine contract leaves this array empty.
  if [ "${#selected_cases[@]}" -gt 0 ]; then
    for entry in "${selected_cases[@]}"; do echo "${entry%% *}"; done
  fi
  exit 0
fi

# Appended to the closing verdict so a filtered run can never be read as a full
# one. Empty for a full run, which keeps that line byte-identical to before.
scope_note=""
if [ -n "$fixture_filter" ]; then
  scope_note=" (filter '$fixture_filter': $n_selected of $total fixtures — NOT a full run)"
  echo "filter '$fixture_filter': $n_selected of $total fixtures selected"
  echo
fi

# Prove the supported-engine contract independently from class behavior. The
# same minimal source must build with LuaLaTeX and fail at the package guard
# (rather than later in fontspec) under both unsupported engines.
if [ "$engine_selected" -eq 1 ]; then
  echo "== $engine_fixture.tex (engine contract) =="
  if ! lualatex -halt-on-error -interaction=nonstopmode "$engine_fixture.tex" \
      > "$engine_fixture-lualatex.stdout" 2>&1; then
    echo "  LuaLaTeX EXPECTED PASS but compile failed"
    fail=1
  else
    echo "  LuaLaTeX build OK"
  fi
  for engine in xelatex pdflatex; do
    job="$engine_fixture-$engine"
    "$engine" -halt-on-error -interaction=nonstopmode -jobname="$job" \
      "$engine_fixture.tex" > "$job.stdout" 2>&1
    rc=$?
    if [ "$rc" -eq 0 ]; then
      echo "  $engine EXPECTED FAILURE but compile succeeded"
      fail=1
    elif ! tr '\n' ' ' < "$job.log" | tr -s ' ' | grep -qF "$engine_needle"; then
      echo "  $engine FAILED for the wrong reason: expected '$engine_needle'"
      fail=1
    else
      echo "  $engine failed at the LuaLaTeX guard as intended"
    fi
  done
  echo
fi

# Issue #252: the header-stack fixture below compiles the worked example
# published in docs/API.md, so it is only worth compiling while the two are the
# same text. Nothing else notices when a documented example is edited and its
# fixture is not -- the fixture keeps building, and the promise it was added to
# keep quietly stops being kept. Compare them before compiling anything.
#
# The documented block is found by its content (the fenced `latex' block that
# declares a document *and* opens a header stack), not by the prose around it,
# so rewording the paragraph above the example does not break this.
#
# It is gated on its own fixture being selected (issue #359): the claim it makes
# is about that fixture, and a run that does not compile it has no business
# reporting on it.
if fixture_matches components-header-stack-doc; then
  doc_source="$root/docs/API.md"
  doc_fixture="$here/components-header-stack-doc.tex"
  echo "== docs/API.md worked example == components-header-stack-doc.tex =="
  awk '
    /^```latex$/          { inblock = 1; buf = ""; next }
    inblock && /^```$/    {
                            inblock = 0
                            if (buf ~ /CDossierHeaderBegin/ && buf ~ /documentclass/)
                              { found++; out = buf }
                            next
                          }
    inblock               { buf = buf $0 "\n" }
    END                   { if (found != 1) exit 1; printf "%s", out }
  ' "$doc_source" > "$here/doc-example.stdout"
  if [ $? -ne 0 ]; then
    echo "  FAILED to locate exactly one worked example in docs/API.md"
    fail=1
  else
    awk '/^\\documentclass/ { p = 1 } p' "$doc_fixture" > "$here/doc-fixture.stdout"
    if diff -u "$here/doc-example.stdout" "$here/doc-fixture.stdout" > "$here/doc-example.diff"; then
      echo "  documented example and fixture are identical"
    else
      echo "  DRIFTED — the fixture no longer compiles what docs/API.md publishes:"
      sed 's/^/    /' "$here/doc-example.diff"
      fail=1
    fi
  fi
  echo
fi

# A filter selecting only the engine contract leaves this array empty, and a
# bare "${selected_cases[@]}" would then be an unbound-variable error under
# `set -u' in bash 3.2. The ${a[@]+"${a[@]}"} form expands to nothing instead.
for entry in ${selected_cases[@]+"${selected_cases[@]}"}; do
  base="${entry%% *}"; rest="${entry#* }"
  expect="${rest%%|*}"; needle=""; once=""
  [ "$rest" != "$expect" ] && needle="${rest#*|}"
  if [ "$expect" = "fail-once" ]; then once="${needle##*|}"; needle="${needle%|*}"; fi
  tex="$base.tex"
  echo "== $tex ($expect) =="
  if [ ! -f "$tex" ]; then echo "  MISSING fixture $tex"; fail=1; continue; fi

  # `fail-once' counts reports across the whole preamble, so it must not stop
  # at the first one. Every other expectation keeps -halt-on-error. The flag is
  # spelled out in both branches rather than held in an array, because an empty
  # array expansion is an unbound-variable error under `set -u' in bash 3.2.
  if [ "$expect" = "fail-once" ]; then
    lualatex -interaction=nonstopmode "$tex" > "$base.stdout" 2>&1
  else
    lualatex -halt-on-error -interaction=nonstopmode "$tex" > "$base.stdout" 2>&1
  fi
  rc=$?

  case "$expect" in
    pass)
      if [ "$rc" -ne 0 ]; then
        echo "  EXPECTED PASS but compile failed (see $base.log)"; fail=1; continue
      fi
      # Academic-letter footers include the total page count, which is resolved
      # by the label written on the first LuaLaTeX pass.
      if [[ "$base" = letter-academic-* || "$base" = statement-* ]]; then
        lualatex -halt-on-error -interaction=nonstopmode "$tex" >> "$base.stdout" 2>&1
        rc=$?
        if [ "$rc" -ne 0 ]; then
          echo "  EXPECTED PASS but footer rerun failed (see $base.log)"; fail=1; continue
        fi
      fi
      unexpected="$(grep -iE 'Warning:|Missing character|Font shape.*undefined|substituting|Overfull' "$base.log" \
                    | grep -viE "$allow" || true)"
      if [ -n "$unexpected" ]; then
        echo "  UNEXPECTED LOG LINES:"; printf '%s\n' "$unexpected" | sed 's/^/    /'; fail=1
      else
        echo "  build OK, log clean"
      fi
      ;;
    fail|fail-once)
      if [ "$rc" -eq 0 ]; then
        echo "  EXPECTED FAILURE but compile succeeded"; fail=1; continue
      fi
      # A message longer than the terminal width is wrapped, and TeX prefixes
      # every continuation line with the reporting module in parentheses. That
      # marker lands mid-sentence and would break any needle spanning the wrap,
      # so it is removed before matching. Dropping it costs nothing: the module
      # is still named in the "! Package <module> Error:" opening.
      flat="$(tr '\n' ' ' < "$base.log" | tr -s ' ' \
        | sed 's/(careerdossier-[a-z]*)[[:space:]]*/ /g' | tr -s ' ')"
      if [ -n "$needle" ] && ! printf '%s' "$flat" | grep -qF "$needle"; then
        echo "  FAILED for the wrong reason: expected '$needle' in the log"; fail=1
      elif [ -n "$once" ]; then
        # -o prints one line per match, so this counts occurrences rather than
        # matching lines; the log has already been flattened to a single line.
        count="$(printf '%s' "$flat" | grep -oF "$once" | wc -l | tr -d ' ')"
        if [ "$count" != "1" ]; then
          echo "  REPORTED $count TIMES, expected exactly 1: '$once'"; fail=1
        else
          echo "  failed as intended, reported once ($needle)"
        fi
      else
        echo "  failed as intended${needle:+ ($needle)}"
      fi
      ;;
  esac
done

echo
[ "$fail" -eq 0 ] && echo "ALL SMOKE FIXTURES PASSED$scope_note" \
                  || echo "SMOKE FIXTURES FAILED$scope_note"
exit "$fail"
