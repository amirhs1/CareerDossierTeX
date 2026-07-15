#!/usr/bin/env bash
# run.sh — CareerDossierTeX smoke runner (Phase 1)
#
# Compiles each fixture with XeLaTeX and checks it against an expected outcome:
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
# Requirements: xelatex. Run from anywhere; the repository root is put on
# TEXINPUTS so the root classes and packages resolve.
set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../.." && pwd)"
cd "$here"
export TEXINPUTS="$root:${TEXINPUTS:-}"
fail=0

# Warnings tolerated in a "pass" build. Kept short and justified; mirrors the
# extraction runner. hyperref/geometry are expected loads; the ...Off ligature
# notices come from fonts without those OpenType tables.
allow='not available for font|Ligatures=CommonOff|ContextualOff, DiscretionaryOff|rerun|Reading font info|geometry|hyperref|fancyhdr'

# Fixture expectations: "<basename> <pass|fail> [expected log substring]".
# The substring is matched against the log with whitespace flattened, so it may
# span the log's wrapped lines.
cases=(
  "resume-valid pass"
  "resume-standard-density pass"
  "resume-missing-name fail|required profile field 'name' is not"
  "resume-bad-fontsize fail|only accepts predefined values"
  "resume-unknown-option fail|Unknown class option 'paper'"
  "resume-unknown-entry-key fail|Unknown CDossierEntry key 'employer'"
)

for entry in "${cases[@]}"; do
  base="${entry%% *}"; rest="${entry#* }"
  expect="${rest%%|*}"; needle=""
  [ "$rest" != "$expect" ] && needle="${rest#*|}"
  tex="$base.tex"
  echo "== $tex ($expect) =="
  if [ ! -f "$tex" ]; then echo "  MISSING fixture $tex"; fail=1; continue; fi

  xelatex -halt-on-error -interaction=nonstopmode "$tex" > "$base.stdout" 2>&1
  rc=$?

  case "$expect" in
    pass)
      if [ "$rc" -ne 0 ]; then
        echo "  EXPECTED PASS but compile failed (see $base.log)"; fail=1; continue
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
      flat="$(tr '\n' ' ' < "$base.log" | tr -s ' ')"
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
