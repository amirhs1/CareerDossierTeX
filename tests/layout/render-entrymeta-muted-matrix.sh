#!/usr/bin/env bash
# render-entrymeta-muted-matrix.sh — build the {column,inline} x
# {italic,gray,both,plain} reference matrix for the résumé and CV
# (issues #230, #271, #324).
#
# `entrymeta' and `muted' are the two options that both land on the same piece
# of the page: the entry heading's dates and location. `entrymeta' decides where
# that metadata sits and `muted' decides how it is de-emphasised, so the pair has
# to be reviewed as a grid rather than one option at a time. The combination
# worth looking hardest at is `entrymeta=inline' with an italic-bearing `muted',
# because that is the only place a de-emphasised run sits immediately beside the
# separator instead of at the far margin — the separator itself is deliberately
# never italic (see \CDossierEntryMetaSeparator), and this matrix is where a
# reviewer confirms that reads correctly rather than merely holds in a .tlg.
#
# `muted=plain' (issue #324) is the one column where the metadata carries no
# de-emphasis at all, so it is where a reviewer judges whether position and
# content still separate the cells from the title — under `inline', where they
# share the line, that judgement rests on the separator alone. It is also the
# class default, so `*-column-plain' is the appearance a document that sets
# neither option gets, and it carries the most review weight of the sixteen.
#
# Every other option is left at its class default. This is deliberate and is
# what separates this matrix from `review-matrix' (issue #147), which sweeps
# fontsize and margin with the semantic options fixed. Sweeping all four at once
# would be 72 PDFs and would not isolate anything; here fontsize, margin, paper,
# and bodyfont are whatever the class chooses, so every visible difference
# between two PDFs in this set is attributable to the two options named in its
# filename.
#
# "Whatever the class chooses" is not the same value for every record class --
# the CV's class default (12pt) differs from what its own two-page fixture
# declares (11pt), so the record names the *resolved* fontsize/margin/paper/
# bodyfont per class rather than asserting the category, and flags any place a
# resolved value differs from what the source fixture declares (issue #336).
# The resolved values are read back from the build itself (a `\typeout' probe
# reads the public \CDossierBodySize/\CDossierPageMargin tokens and the core
# \paperwidth/\rmdefault primitives) rather than transcribed as script
# literals, so the record cannot drift from the class defaults it describes.
#
# `entrymeta' exists only on the two record classes, so only those two are built
# — the letter and statement classes have no entry headings. Each is represented
# by its existing canonical two-page fixture, so the grid exercises entries and
# bullet lists under real page-break pressure rather than a one-page stub, and
# the CV fixture additionally carries its publication list.
#
# Every combination must actually compile; a genuine compile failure aborts the
# run. Overfull boxes, missing glyphs, font substitutions, and unresolved
# references are instead collected as warnings, so one bad combination does not
# stop the other fifteen from being produced for review.
#
# Whether the rendered result reads well — whether `|' is the right mark at the
# default size, whether gray metadata beside an upright separator is legible,
# whether the inline form crowds the heading — is a human visual review. This
# script produces the evidence; it does not judge it.
#
# PDFs, logs, and the review record are generated evidence under the gitignored
# build/ directory. They must not be committed.
#
# Requirements: lualatex. Run from anywhere; the repository root is placed on
# TEXINPUTS.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../.." && pwd)"
work="$(mktemp -d "${TMPDIR:-/tmp}/careerdossier-entrymeta-muted-matrix.XXXXXX")"
output="$root/build/entrymeta-muted-matrix"
trap 'rm -rf "$work"' EXIT

if ! command -v lualatex >/dev/null 2>&1; then
  echo "MISSING required command: lualatex"
  exit 1
fi

mkdir -p "$output"
find "$output" -maxdepth 1 -type f \( -name '*.pdf' -o -name '*.log' -o -name '*.txt' \) -delete

export TEXINPUTS="$here:$root:${TEXINPUTS:-}"

# `entrymeta' is the outer loop, so both the build order and a directory listing
# group all four `muted' values of one placement together — the order a reviewer
# compares them in, because the placement is the larger visual decision and the
# de-emphasis is the variation within it.
placements=(column inline)
emphases=(italic gray both plain)
diagnostic_jobs=()

# Injected after `\begin{document}' so the four class-resolved values a
# reviewer needs (fontsize, margin, paper, bodyfont) land in the .log without
# rendering into the PDF. \CDossierBodySize and \CDossierPageMargin are the
# public resolved-token accessors careerdossier-tokens.sty exposes; paper and
# bodyfont have no such accessor, so \paperwidth and \rmdefault (core
# LaTeX/fontspec primitives, set by the class's own option processing) stand
# in for them instead of reaching into either class's private option
# variables.
option_probe='\typeout{CDOSSIER-PROBE-FONTSIZE:\the\CDossierBodySize}
\typeout{CDOSSIER-PROBE-MARGIN:\the\CDossierPageMargin}
\typeout{CDOSSIER-PROBE-PAPERWIDTH:\the\paperwidth}
\typeout{CDOSSIER-PROBE-BODYFONT:\rmdefault}'

# Map a probed raw value back to the option keyword a reviewer recognizes.
#
# The keyword is what the record has to print, because the fixture declares
# keywords and the whole point is to compare the two. The measurement stays in
# the record beside it, so the mapping is auditable rather than taken on trust.
#
# These literals are the *definitions* of the keywords -- `narrow' is 0.5in and
# US Letter is 8.5in wide -- not a copy of any class's default. A class that
# changes which keyword it defaults to is still reported correctly, which is
# the drift this reads back from the build to avoid. A change to what a keyword
# itself means is caught the other way: the value falls through to UNRESOLVED
# and fails the run, rather than silently mislabeling the record.
resolve_fontsize() {
  case "$1" in
    10.0pt) echo "10pt" ;;
    11.0pt) echo "11pt" ;;
    12.0pt) echo "12pt" ;;
    *) echo "UNRESOLVED(${1:-empty})" ;;
  esac
}

resolve_margin() {
  case "$1" in
    72.26999pt) echo "normal" ;;
    36.135pt) echo "narrow" ;;
    *) echo "UNRESOLVED(${1:-empty})" ;;
  esac
}

resolve_paper() {
  case "$1" in
    614.295pt) echo "letter" ;;
    597.50787pt) echo "a4" ;;
    *) echo "UNRESOLVED(${1:-empty})" ;;
  esac
}

resolve_bodyfont() {
  case "$1" in
    *termes*) echo "serif" ;;
    *heros*) echo "sans" ;;
    *) echo "UNRESOLVED(${1:-empty})" ;;
  esac
}

# What the fixture's own, unmodified \documentclass line declares for one
# option key, or empty when the fixture leaves that key to the class default.
# Neither fixture sets `paper' or `bodyfont', so the no-match case is the
# common one -- `|| true' keeps that from tripping `set -e', since grep
# exiting 1 on no match is expected here, not an error.
declared_option() {
  local template="$1" key="$2" line match
  line="$(grep -m1 '^\\documentclass' "$here/$template")"
  match="$(printf '%s' "$line" | grep -oE "${key}=[A-Za-z0-9]+" || true)"
  printf '%s' "${match#*=}"
}

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

# Rewrite the fixture's \documentclass line with the entrymeta/muted combination
# under test, and with nothing else: the fixtures name fontsize and margin
# explicitly, and dropping those is what makes this a default-everything-else
# matrix. Using awk, not sed, keeps this portable across BSD (macOS) and GNU
# (CI) tool differences.
render_class_matrix() {
  local class="$1" template="$2" prefix="$3"
  local placement emphasis job newline

  for placement in "${placements[@]}"; do
    for emphasis in "${emphases[@]}"; do
      job="${prefix}-${placement}-${emphasis}"
      # ENVIRON, not -v, carries the replacement: awk's -v assignment runs
      # backslash-escape processing on its value, which silently eats the
      # leading backslash off \documentclass. ENVIRON is not escape-processed.
      newline="\\documentclass[entrymeta=${placement}, muted=${emphasis}]{${class}}"
      NEWLINE="$newline" PROBE="$option_probe" awk '
        $0 ~ /^\\documentclass/ { print ENVIRON["NEWLINE"]; next }
        # A bracket expression, not a backslash escape: an open brace starts an
        # ERE interval, and awks differ on how they read the escaped form.
        # Keep apostrophes out of these comments -- they sit inside the shell
        # single-quoted awk program, and one would close it mid-script.
        $0 ~ /^\\begin[{]document[}]/ { print; print ENVIRON["PROBE"]; next }
        { print }
      ' "$here/$template" >"$work/$job.tex"
      compile_and_check "$job" "$work/$job.tex"
    done
  done

  # Every combination in this class strips the same four options, so the
  # probe resolves identically across all eight; reading it from the first
  # job's .log avoids compiling a ninth job just to record it.
  local probe_log="$work/${prefix}-${placements[0]}-${emphases[0]}.log"
  local raw_fontsize raw_margin raw_paper raw_bodyfont
  local resolved_fontsize resolved_margin resolved_paper resolved_bodyfont
  # `|| true' on each grep: a missing marker (the probe failed to reach the
  # log at all) must not abort the run here via `set -e' -- it should instead
  # fall through to the explicit UNRESOLVED check below and fail loudly with
  # a message that names which value and which log.
  raw_fontsize="$(grep -oE 'CDOSSIER-PROBE-FONTSIZE:\S+' "$probe_log" | head -1 | cut -d: -f2 || true)"
  raw_margin="$(grep -oE 'CDOSSIER-PROBE-MARGIN:\S+' "$probe_log" | head -1 | cut -d: -f2 || true)"
  raw_paper="$(grep -oE 'CDOSSIER-PROBE-PAPERWIDTH:\S+' "$probe_log" | head -1 | cut -d: -f2 || true)"
  raw_bodyfont="$(grep -oE 'CDOSSIER-PROBE-BODYFONT:\S+' "$probe_log" | head -1 | cut -d: -f2 || true)"

  resolved_fontsize="$(resolve_fontsize "$raw_fontsize")"
  resolved_margin="$(resolve_margin "$raw_margin")"
  resolved_paper="$(resolve_paper "$raw_paper")"
  resolved_bodyfont="$(resolve_bodyfont "$raw_bodyfont")"

  local resolved_value
  for resolved_value in "$resolved_fontsize" "$resolved_margin" "$resolved_paper" "$resolved_bodyfont"; do
    case "$resolved_value" in
      UNRESOLVED\(*\))
        echo "FAILED: could not resolve an option value for $prefix from $probe_log ($resolved_value)"
        exit 1
        ;;
    esac
  done

  local declared_fontsize declared_margin declared_paper declared_bodyfont
  declared_fontsize="$(declared_option "$template" fontsize)"
  declared_margin="$(declared_option "$template" margin)"
  declared_paper="$(declared_option "$template" paper)"
  declared_bodyfont="$(declared_option "$template" bodyfont)"

  # set -e means a bare `&&' chain that ends up false would abort the script,
  # so each check is its own `if', not a chained one-liner.
  local differences=()
  if [ -n "$declared_fontsize" ] && [ "$declared_fontsize" != "$resolved_fontsize" ]; then
    differences+=("fontsize: fixture declares ${declared_fontsize}, matrix renders at ${resolved_fontsize}")
  fi
  if [ -n "$declared_margin" ] && [ "$declared_margin" != "$resolved_margin" ]; then
    differences+=("margin: fixture declares ${declared_margin}, matrix renders at ${resolved_margin}")
  fi
  if [ -n "$declared_paper" ] && [ "$declared_paper" != "$resolved_paper" ]; then
    differences+=("paper: fixture declares ${declared_paper}, matrix renders at ${resolved_paper}")
  fi
  if [ -n "$declared_bodyfont" ] && [ "$declared_bodyfont" != "$resolved_bodyfont" ]; then
    differences+=("bodyfont: fixture declares ${declared_bodyfont}, matrix renders at ${resolved_bodyfont}")
  fi

  {
    echo "    $template declares: fontsize=${declared_fontsize:-<unset>}, margin=${declared_margin:-<unset>}, paper=${declared_paper:-<unset>}, bodyfont=${declared_bodyfont:-<unset>}"
    echo "    matrix renders at:   fontsize=${resolved_fontsize}, margin=${resolved_margin}, paper=${resolved_paper}, bodyfont=${resolved_bodyfont}"
    # The measurements the line above was derived from, so the record carries
    # its own evidence: a reader can check the keyword against the value the
    # build actually reported instead of trusting this script's mapping.
    echo "      probed from ${prefix}-${placements[0]}-${emphases[0]}.log: \\CDossierBodySize=${raw_fontsize}, \\CDossierPageMargin=${raw_margin}, \\paperwidth=${raw_paper}, \\rmdefault=${raw_bodyfont}"
    if [ "${#differences[@]}" -eq 0 ]; then
      echo "    identical to what the fixture declares"
    else
      echo "    DIFFERS from what the fixture declares -- every ${prefix}-*.pdf in this set is"
      echo "    one document rendered at these class defaults, not at the fixture's own options:"
      printf '      %s\n' "${differences[@]}"
    fi
  } >"$work/$prefix-options.txt"
}

echo "Building résumé entrymeta/muted matrix (resume-two-page.tex)"
render_class_matrix careerdossier-resume resume-two-page.tex resume

echo
echo "Building CV entrymeta/muted matrix (cv-two-page.tex)"
render_class_matrix careerdossier-cv cv-two-page.tex cv

count="$(find "$output" -maxdepth 1 -type f -name '*.pdf' | wc -l | tr -d ' ')"
if [ "$count" -ne 16 ]; then
  echo "FAILED: expected 16 PDFs, found $count"
  exit 1
fi

{
  echo "# CareerDossierTeX entrymeta/muted reference-matrix record (issues #230, #271, #324)"
  echo "generated-utc: $(date -u +'%Y-%m-%dT%H:%M:%SZ')"
  echo "commit: $(git -C "$root" rev-parse HEAD 2>/dev/null || echo unavailable)"
  echo "combinations: 2 placements x 4 de-emphasis values x 2 record classes = 16"
  echo "file naming: <type>-<entrymeta>-<muted>.pdf"
  echo "record classes (fontsize/margin/paper/bodyfont are every other option;"
  echo "resolved values below are read from the build, not asserted; <unset> means"
  echo "the fixture leaves that key to the class default):"
  echo "  résumé - resume-two-page.tex"
  cat "$work/resume-options.txt"
  echo "  CV     - cv-two-page.tex"
  cat "$work/cv-options.txt"
  echo
  echo "review-matrix (issue #147) sweeps fontsize and margin explicitly with the"
  echo "semantic options fixed, so it states its sizes outright and never has this"
  echo "ambiguity -- use it to ask 'what does this look like at a chosen size', and"
  echo "this matrix to ask 'what does entrymeta/muted look like at this class's own"
  echo "default'."
  echo
  echo "What to compare:"
  echo "  down a column  - the four muted values at one placement"
  echo "  across a row   - column vs inline at one muted value"
  echo "  hardest case   - *-inline-italic and *-inline-both: the only place a"
  echo "                   de-emphasised run sits directly beside the separator,"
  echo "                   which must stay upright while the cell after it slants"
  echo "  plain column   - *-*-plain carries no de-emphasis at all and is the"
  echo "                   class default, so *-column-plain is what a document"
  echo "                   that sets neither option renders; judge whether"
  echo "                   position and content still separate the metadata"
  echo
  if [ "${#diagnostic_jobs[@]}" -eq 0 ]; then
    echo "log diagnostics: none"
  else
    echo "log diagnostics: ${#diagnostic_jobs[@]} combination(s) logged a warning — see the matching .log:"
    printf '  %s\n' "${diagnostic_jobs[@]}"
  fi
  echo
  echo "Review each PDF using the checklist in CONTRIBUTING.md."
} >"$output/review-record.txt"

echo
echo "ENTRYMETA/MUTED REFERENCE MATRIX BUILT"
echo "Artifacts: $output"
if [ "${#diagnostic_jobs[@]}" -gt 0 ]; then
  echo "${#diagnostic_jobs[@]} combination(s) logged a warning: ${diagnostic_jobs[*]}"
fi
