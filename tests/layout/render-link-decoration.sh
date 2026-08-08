#!/usr/bin/env bash
# render-link-decoration.sh — build the print/screen link-decoration reference
# pair for visual review (issue #278).
#
# `medium=screen' draws a rule under author-written \href anchor text and
# `medium=print' draws nothing. Everything a machine can decide about that is
# already decided elsewhere: tests/regression pins which branch runs,
# tests/extraction pins that the two media extract identically, tests/tagging
# pins that the decorated run stays in the structure tree, and tests/links pins
# that no address link was reboxed. What none of them can decide is whether the
# rule is the right weight, sits at the right depth, and reads as `this is a
# link' rather than as emphasis. That is what this set is for.
#
# Three things to look at, in order:
#
#   1. The anchor text. Under `screen' it must be unmistakably actionable; under
#      `print' it must be indistinguishable from body text, which is the
#      appearance this toolkit shipped with and is not being changed.
#   2. The rule itself — weight against the section rule above it, clearance
#      under descenders (`p', `g', `y'), and behaviour where an anchor wraps
#      across a line break.
#   3. The contact line, which issue #278 settled deliberately: it is NOT
#      decorated, under either medium. Its items are addresses that announce
#      themselves, and a rule under the e-mail and website but not under the
#      phone or the location reads as `these two are emphasised' rather than
#      `these are links'. Confirm the undecorated contact line still reads as a
#      set of links in the screen rendering, since that is the reading this
#      choice rests on.
#
# The letter fixture is included because it carries the one case the résumé does
# not: an author's own \href whose anchor text is itself an address. The toolkit
# suppresses decoration on the links it renders, not on the ones an author
# writes, so that anchor is decorated — a reviewer should confirm a ruled
# address still reads correctly and still wraps.
#
# PDFs and logs are generated review evidence under the gitignored build/
# directory. They must not be committed.
#
# Requirements: lualatex. Run from anywhere; the repository root is placed on
# TEXINPUTS.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../.." && pwd)"
work="$(mktemp -d "${TMPDIR:-/tmp}/careerdossier-link-decoration.XXXXXX")"
output="$root/build/link-decoration-review"
trap 'rm -rf "$work"' EXIT

if ! command -v lualatex >/dev/null 2>&1; then
  echo "MISSING required command: lualatex"
  exit 1
fi

mkdir -p "$output"
find "$output" -maxdepth 1 -type f \( -name '*.pdf' -o -name '*.log' -o -name '*.txt' \) -delete

export TEXINPUTS="$here:$root:${TEXINPUTS:-}"

media=(print screen)
diagnostic_jobs=()

compile_and_check() {
  local job="$1" source="$2" pass
  for pass in 1 2; do
    if ! (cd "$root" && lualatex -output-directory="$work" -jobname="$job" \
        -halt-on-error -interaction=nonstopmode "$source") \
        >"$work/$job.stdout" 2>&1; then
      echo "FAILED: $job did not compile on pass $pass (see $work/$job.stdout)"
      exit 1
    fi
  done

  local unexpected pages
  unexpected="$(grep -iE \
    'Warning:|Missing character|Font shape.*undefined|substituting|Undefined control sequence|Overfull' \
    "$work/$job.log" | grep -viE 'Neither unicode-math nor lua-unicode-math' || true)"
  pages="$(grep -oE 'Output written on .*\(([0-9]+) page' "$work/$job.log" \
           | grep -oE '\(([0-9]+) page' | grep -oE '[0-9]+' | tail -1)"
  cp "$work/$job.pdf" "$output/$job.pdf"
  cp "$work/$job.log" "$output/$job.log"

  if [ -n "$unexpected" ]; then
    diagnostic_jobs+=("$job")
    echo "  built: $job.pdf (${pages:-?} pages) — WARNING: see $job.log"
    printf '%s\n' "$unexpected" | sed 's/^/    /'
  else
    echo "  built: $job.pdf (${pages:-?} pages)"
  fi
}

# Rewrite only the `medium' value in the fixture's \documentclass line, leaving
# every other option it names in place: the two renderings must differ in the
# medium and in nothing else, or the comparison proves nothing. awk rather than
# sed, for the same BSD/GNU portability reason as the other matrix scripts here.
render_medium_pair() {
  local fixture="$1" prefix="$2"
  local medium job

  for medium in "${media[@]}"; do
    job="${prefix}-${medium}"
    MEDIUM="$medium" awk '
      $0 ~ /^\\documentclass/ {
        line = $0
        if (line ~ /medium *= *[a-z]+/) {
          sub(/medium *= *[a-z]+/, "medium=" ENVIRON["MEDIUM"], line)
        } else {
          sub(/\[/, "[medium=" ENVIRON["MEDIUM"] ", ", line)
        }
        print line
        next
      }
      { print }
    ' "$here/$fixture" >"$work/$job.tex"
    compile_and_check "$job" "$work/$job.tex"
  done
}

echo "Building résumé link-decoration pair (resume-link-decoration-screen.tex)"
render_medium_pair resume-link-decoration-screen.tex resume

echo
echo "Building letter link-decoration pair (letter-long-fields.tex)"
render_medium_pair letter-long-fields.tex letter

count="$(find "$output" -maxdepth 1 -type f -name '*.pdf' | wc -l | tr -d ' ')"
if [ "$count" -ne 4 ]; then
  echo "FAILED: expected 4 PDFs, found $count"
  exit 1
fi

{
  echo "# CareerDossierTeX link-decoration reference record (issue #278)"
  echo "generated-utc: $(date -u +'%Y-%m-%dT%H:%M:%SZ')"
  echo "commit: $(git -C "$root" rev-parse HEAD 2>/dev/null || echo unavailable)"
  echo "combinations: 2 media x 2 families = 4"
  echo "file naming: <family>-<medium>.pdf"
  echo "sources:"
  echo "  résumé - tests/layout/resume-link-decoration-screen.tex"
  echo "  letter - tests/layout/letter-long-fields.tex"
  echo "only the 'medium' option differs between the two files of a pair"
  echo
  echo "What to compare:"
  echo "  within a pair - the ONLY visible difference may be a rule under"
  echo "                  author-written \\href anchor text"
  echo "  screen file   - is the anchor unmistakably actionable? is the rule the"
  echo "                  same weight as the section rule? does it clear the"
  echo "                  descenders in 'p', 'g', 'y'? does a wrapped anchor keep"
  echo "                  its rule on both lines?"
  echo "  print file    - must be indistinguishable from the shipped appearance"
  echo "  contact line  - undecorated under BOTH media, by the decision recorded"
  echo "                  in issue #278 §5; confirm it still reads as links"
  echo "  letter-screen - its \\href anchor text is itself an address, so it IS"
  echo "                  ruled; confirm a ruled address reads and wraps well"
  echo
  if [ "${#diagnostic_jobs[@]}" -eq 0 ]; then
    echo "log diagnostics: none"
  else
    echo "log diagnostics: ${#diagnostic_jobs[@]} rendering(s) logged a warning — see the matching .log:"
    printf '  %s\n' "${diagnostic_jobs[@]}"
  fi
  echo
  echo "Review each PDF using the checklist in CONTRIBUTING.md."
} >"$output/review-record.txt"

echo
echo "LINK-DECORATION REFERENCE PAIR BUILT"
echo "Artifacts: $output"
if [ "${#diagnostic_jobs[@]}" -gt 0 ]; then
  echo "${#diagnostic_jobs[@]} rendering(s) logged a warning: ${diagnostic_jobs[*]}"
fi
