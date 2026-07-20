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
# Screen-reader review (VoiceOver, NVDA) stays manual and is NOT run here; see
# docs/guides/ats-extraction.md for the checklists and recorded results.
#
# Scope: these fixtures validate four named artifacts. Passing them is not a
# PDF/UA, WCAG, accessibility, or ATS conformance claim for arbitrary user
# documents.
#
# Requirements: lualatex and pdftotext (Poppler) are required. veraPDF, MuPDF
# (mutool), Biber, and PDFKit (macOS) gates are skipped with a notice when
# unavailable, and the closing summary lists exactly which gates did not run.
#
# Regenerate extraction baselines intentionally with:  ./run.sh --update
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

update=0
[ "${1:-}" = "--update" ] && update=1
fail=0
skipped=()

for command in lualatex pdftotext; do
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

  if [ "$base" = resume ] || [ "$base" = cv ]; then
    grep -qa '/S /section' "$pdf" || record_failure "$base has no semantic section heading"
    grep -Fqa '/section [/H1' "$pdf" || record_failure "$base section is not role-mapped to H1"
    grep -qa '/S /itemize' "$pdf" || record_failure "$base has no semantic list"
    grep -qa '/S /item ' "$pdf" || record_failure "$base has no semantic list item"
    grep -qa '/S /itembody' "$pdf" || record_failure "$base has no semantic list-item body"
  fi

  if [ "$base" = cv ]; then
    grep -qa '/Artifact BMC' "$pdf" \
      || record_failure "cv running header/folio are not artifacts"
  fi

  if [ "$base" = academic-letter ]; then
    grep -qa '/Artifact BMC' "$pdf" \
      || record_failure "academic-letter repeated footer is not an artifact"
  fi
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
    mutool draw -F txt -o - "$work/$base.pdf" 2>/dev/null | normalize \
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

check_visual_equivalence() {
  local base="$1" tagged="$work/$base.bbox" plain="$work/$base-untagged.bbox"
  # Compare every rendered word and its bounding box to one decimal point.
  # This catches material layout movement while tolerating sub-tenth-point
  # placement noise introduced by zero-width tagging whatsits.
  pdftotext -bbox "$work/$base.pdf" - \
    | grep '<word ' | sed -E 's/([0-9]+\.[0-9])[0-9]+"/\1"/g' >"$tagged"
  pdftotext -bbox "$work/$base-untagged.pdf" - \
    | grep '<word ' | sed -E 's/([0-9]+\.[0-9])[0-9]+"/\1"/g' >"$plain"
  if ! diff -u "$plain" "$tagged" >"$work/$base-layout.diff"; then
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

for base in resume cv letter academic-letter; do
  echo "== $base =="
  compile_fixture "$base.tex" "$base" || continue
  compile_fixture "$base-untagged.tex" "$base-untagged" || continue
  check_structure "$base"
  check_extraction "$base"
  check_untagged "$base"
  check_visual_equivalence "$base"

  if [ "$have_verapdf" -eq 1 ]; then
    compile_fixture "$base-ua2.tex" "$base-ua2" && validate_ua2 "$base"
  fi
done

if [ "$have_biber" -eq 1 ]; then
  echo
  check_biblatex_feasibility
fi

echo
if [ "${#skipped[@]}" -gt 0 ]; then
  echo "GATES NOT RUN on this machine:"
  printf '  - %s\n' "${skipped[@]}"
  echo
fi

if [ "$fail" -eq 0 ]; then
  if [ "$update" -eq 1 ]; then
    echo "BASELINES UPDATED — review the diff before committing."
  else
    echo "ALL TAGGING FIXTURES PASSED"
  fi
else
  echo "TAGGING FIXTURES FAILED"
fi
echo "Reports: $reports"
exit "$fail"
