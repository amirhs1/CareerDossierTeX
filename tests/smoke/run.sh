#!/usr/bin/env bash
# run.sh — CareerDossierTeX smoke runner (Phase 1)
#
# Compiles each fixture with LuaLaTeX and checks it against an expected outcome:
#
#   pass  — must compile with exit 0 and a clean log (only allowlisted warnings)
#   fail  — must stop with a nonzero exit, and its log must contain the expected
#           diagnostic substring (proving the *intended* error fired, not an
#           unrelated one)
#
# This is the supported-build and required-failure gate for the résumé class.
# It complements the layout runner (page stress) and the extraction runner
# (text layer and reading order).
#
# Requirements: lualatex, xelatex, and pdflatex. Run from anywhere; the
# repository root is put on TEXINPUTS so the root classes and packages resolve.
set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../.." && pwd)"
cd "$here"
export TEXINPUTS="$root:${TEXINPUTS:-}"
fail=0

# Prove the supported-engine contract independently from class behavior. The
# same minimal source must build with LuaLaTeX and fail at the package guard
# (rather than later in fontspec) under both unsupported engines.
engine_fixture="engine-contract"
engine_needle="Compile with lualatex, not"
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

# Warnings tolerated in a "pass" build. Kept short and justified; mirrors the
# extraction runner. hyperref/geometry are expected loads; the ...Off ligature
# notices come from fonts without those OpenType tables. The tagpdf math-font
# notice is expected for the focused tagged text fixture, which contains no
# mathematics and intentionally loads neither Unicode-math package.
allow='not available for font|Ligatures=CommonOff|ContextualOff, DiscretionaryOff|Neither unicode-math nor lua-unicode-math|rerun|Reading font info|geometry|hyperref|fancyhdr'

# Fixture expectations: "<basename> <pass|fail> [expected log substring]".
# The substring is matched against the log with whitespace flattened, so it may
# span the log's wrapped lines.
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
  "resume-density-option fail|Supported options are 'fontsize', 'margin', 'paper', 'bodyfont', and 'medium'."
  "resume-missing-name fail|required profile field 'name' is not"
  "resume-bad-fontsize fail|Unknown 'fontsize' value '9pt' for careerdossier-resume."
  "resume-bad-paper fail|Unknown 'paper' value 'legal' for careerdossier-resume."
  "resume-bad-bodyfont fail|Unknown 'bodyfont' value 'decorative' for careerdossier-resume."
  "resume-bad-medium fail|Unknown 'medium' value 'paper' for careerdossier-resume."
  "resume-unknown-option fail|Unknown class option 'format'"
  "resume-unknown-entry-key fail|Unknown CDossierEntry key 'employer'"
  "resume-contact-too-wide fail|is wider than the available contact-line width."
  "resume-shared-profile pass"
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
  "cv-density-option fail|Supported options are 'fontsize', 'margin', 'paper', 'bodyfont', and 'medium'."
  "cv-missing-name fail|required profile field 'name' is not"
  "cv-bad-fontsize fail|Unknown 'fontsize' value '9pt' for careerdossier-cv."
  "cv-bad-paper fail|Unknown 'paper' value 'legal' for careerdossier-cv."
  "cv-bad-bodyfont fail|Unknown 'bodyfont' value 'decorative' for careerdossier-cv."
  "cv-bad-medium fail|Unknown 'medium' value 'paper' for careerdossier-cv."
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
  "letter-bad-fontsize fail|Unknown 'fontsize' value '13pt' for careerdossier-letter."
  "letter-bad-margin fail|Unknown 'margin' value 'wide' for careerdossier-letter."
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
  "statement-bad-medium fail|Unknown 'medium' value 'paper' for careerdossier-statement."
  "statement-empty-type fail|The key 'cdossier/statement/type' requires a value"
  "statement-bad-type fail|Unknown statement type 'grant'"
  "statement-bad-paper fail|Unknown 'paper' value 'legal' for careerdossier-statement."
  "statement-bad-fontsize fail|Unknown 'fontsize' value '13pt' for careerdossier-statement."
  "statement-bad-margin fail|Unknown 'margin' value 'wide' for careerdossier-statement."
  "statement-bad-bodyfont fail|Unknown 'bodyfont' value 'decorative' for careerdossier-statement."
  "statement-unknown-option fail|Unknown class option 'format'"
  "statement-unknown-meta-key fail|Unknown \CDossierStatementSetup key"
  "statement-missing-name fail|required profile field 'name' is not"
  "statement-missing-email fail|required profile field 'email' is not"
  "statement-research-missing-affiliation fail|required profile field 'affiliation'"
  "statement-artist-missing-website fail|required profile field 'website'"
)

for entry in "${cases[@]}"; do
  base="${entry%% *}"; rest="${entry#* }"
  expect="${rest%%|*}"; needle=""
  [ "$rest" != "$expect" ] && needle="${rest#*|}"
  tex="$base.tex"
  echo "== $tex ($expect) =="
  if [ ! -f "$tex" ]; then echo "  MISSING fixture $tex"; fail=1; continue; fi

  lualatex -halt-on-error -interaction=nonstopmode "$tex" > "$base.stdout" 2>&1
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
    fail)
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
      else
        echo "  failed as intended${needle:+ ($needle)}"
      fi
      ;;
  esac
done

echo; [ "$fail" -eq 0 ] && echo "ALL SMOKE FIXTURES PASSED" || echo "SMOKE FIXTURES FAILED"
exit "$fail"
