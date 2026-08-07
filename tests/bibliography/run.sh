#!/usr/bin/env bash
# Build the focused Biber fixture, compare its extracted text, and reject Biber
# warnings/errors. The baseline pins ydnt ordering and DOI -> e-print -> URL
# precedence against a fixture this suite owns, and deliberately does not pin
# the user-facing example: a baseline extracted from `examples/academic/' would
# turn red on any edit to that example's prose, profile, or database, and the
# test's meaning would decay from "sorting and precedence are correct" to "the
# example is unchanged".
#
# The final section is the complement of that rule rather than an exception to
# it (issue #319). It builds the shipped example and asserts only that it
# rendered as many entries as its database declares. It pins no string, no
# order, no field, no key, and no year, so adding a fourth entry keeps it green
# and the example stays free to change; it cannot become a content baseline
# because it holds no content.
#
# That check has to build the example, because the fixture here cannot exhibit
# the defect it guards. The fixture resolves a directory-local
# `\addbibresource{publications.bib}' with cwd=tests/bibliography, while the
# example writes a root-relative path. When that path does not resolve, Biber
# fails, `\nocite{*}' against no database is not a LaTeX error, latexmk exits 0,
# and a PDF ships with the entries silently missing. Measured: with
# `publications.bib' removed, `make academic-bibliography' exits 0 and produces
# 12297 bytes where a complete build produces 24514.
set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../.." && pwd)"
cd "$here"
export TEXINPUTS="$root:${TEXINPUTS:-}"

base="cv-bibliography"
expected="$base.expected.txt"
update=0
[ "${1:-}" = "--update" ] && update=1

# Every latexmk call here passes -g. Without it latexmk treats an existing
# up-to-date PDF as done, so a run in a directory holding an earlier build
# judges that PDF and reports on the previous state of the package rather than
# the current one — including its Biber warnings, which is how a stale build
# survived a package change during issue #312.
echo "== $base.tex (latexmk + Biber) =="
if ! latexmk -g -lualatex -interaction=nonstopmode -halt-on-error "$base.tex" > "$base.stdout" 2>&1; then
  echo "  BUILD FAILED (see $base.log and $base.blg)"
  exit 1
fi

if [ ! -f "$base.blg" ]; then
  echo "  MISSING Biber log $base.blg"
  exit 1
fi
if grep -Eiq '(^| - )(WARN|ERROR) -' "$base.blg"; then
  echo "  BIBER WARNINGS/ERRORS:"
  grep -Ei '(^| - )(WARN|ERROR) -' "$base.blg" | sed 's/^/    /'
  # If Biber rejected the `date` of every entry that has one, the fault is its
  # date parser, not this fixture's data: the years vanish and the ydnt sort
  # order silently comes out wrong (issue #211). Counting `date` fields rather
  # than entries keeps this correct if a `year`-only entry is added later. Biber
  # is a PAR-packed binary that unpacks its Perl runtime -- including the
  # DateTime modules only the `date` path uses -- into a per-user cache under
  # TMPDIR, which macOS purges periodically. An incomplete cache breaks `date`
  # while the legacy `year` field, which needs no DateTime, keeps working. Name
  # that here so the next reader does not re-derive it; the gate still fails.
  dated="$(grep -Ec '^[[:space:]]*date[[:space:]]*=' publications.bib || true)"
  rejected="$(grep -Eic "Invalid format .* of date field" "$base.blg" || true)"
  if [ "$rejected" -gt 0 ] && [ "$rejected" -eq "$dated" ]; then
    echo
    echo "  DIAGNOSIS: Biber rejected the 'date' field of all $dated entries."
    echo "  This is a local Biber install fault, not a fixture-data problem."
    echo "  The same fixture passes in CI on the pinned TeX Live container, so"
    echo "  it is this install rather than Biber in general. To repair it:"
    echo
    echo "    rm -rf \"\${TMPDIR:-/tmp}\"/par-*   # drop Biber's unpacked cache"
    echo "    biber --version                   # re-unpack, then re-run"
    echo
    echo "  If that does not help, see CONTRIBUTING.md (\"BibLaTeX/Biber"
    echo "  fixture\"). Do not switch the fixture to 'year=' and do not relax"
    echo "  this gate: either would hide a genuinely wrong bibliography."
  fi
  exit 1
fi
unexpected="$(grep -iE 'Warning:|Missing character|Font shape.*undefined|substituting|Overfull' \
  "$base.log" || true)"
if [ -n "$unexpected" ]; then
  echo "  UNEXPECTED LATEX LOG LINES:"
  printf '%s\n' "$unexpected" | sed 's/^/    /'
  exit 1
fi

got="$(pdftotext -enc UTF-8 "$base.pdf" - | sed '/^\f/d' \
  | awk '{ line[NR] = $0 }
         END { last = NR
               while (last > 0 && line[last] ~ /^[[:space:]]*$/) last--
               for (i = 1; i <= last; i++) print line[i] }')"

if [ "$update" -eq 1 ]; then
  printf '%s\n' "$got" > "$expected"
  echo "  baseline updated: $expected"
elif [ ! -f "$expected" ]; then
  echo "  MISSING baseline $expected (run with --update to create)"
  exit 1
elif ! diff -u "$expected" <(printf '%s\n' "$got") > "$base.diff"; then
  echo "  BIBLIOGRAPHY EXTRACTION MISMATCH:"
  sed 's/^/    /' "$base.diff"
  exit 1
else
  echo "  ordering and identifier precedence OK"
fi

echo "  Biber completed without warnings/errors"

# Assert label/entry association from the geometry rather than from pdftotext's
# line grouping (issue #199). The baseline above pins the default extractor's
# *output*, which is what a naive consumer sees, but that output depends on
# Poppler's column heuristic and so can shift with the extractor version. Each
# entry number shares a baseline with the first word of its entry in the page
# content, and that is a property of the PDF itself: check it directly, so a
# future Poppler change is distinguishable from a real regression here.
echo "== $base.pdf (each entry number shares its entry's baseline) =="
pairing="$(pdftotext -bbox "$base.pdf" - \
  | awk -F'"' '
      BEGIN { tol = 2 }
      # <word xMin=".." yMin=".." xMax=".." yMax="..">text</word>
      /<word /{
        text = $0; sub(/^[^>]*>/, "", text); sub(/<\/word>.*$/, "", text)
        xmin = $2 + 0; ymin = $4 + 0; xmax = $6 + 0
        if (text ~ /^[0-9]+\)$/ && labelymin[text] == "") {
          labelymin[text] = ymin; labelxmax[text] = xmax
          order[++n] = text
          next
        }
        # Leftmost word to the right of a label, on that label|s baseline. The
        # tolerance is deliberate: a bibliography line mixes roman, bold, and
        # small text, whose reported yMin differs by a fraction of a point on
        # one and the same typeset baseline. Requiring exact equality would
        # match a later word on the line instead of the entry|s first word.
        for (l in labelymin)
          if (labelymin[l] - ymin < tol && ymin - labelymin[l] < tol \
              && xmin > labelxmax[l] \
              && (entry[l] == "" || xmin < entryxmin[l])) {
            entry[l] = text; entryxmin[l] = xmin; gap[l] = xmin - labelxmax[l]
          }
      }
      END {
        for (i = 1; i <= n; i++) {
          l = order[i]
          if (entry[l] == "")
            printf "UNPAIRED %s (no word shares its baseline)\n", l
          else
            printf "ok %s -> %s (gap %.3fpt)\n", l, entry[l], gap[l]
        }
        if (n == 0) print "NO LABELS FOUND"
      }')"
printf '%s\n' "$pairing" | sed 's/^/    /'
# Here-string, not `printf | grep -q'. Under `pipefail' grep exits on its first
# match and the producer can die of SIGPIPE, so the pipeline reports failure
# precisely when the pattern *did* match — an inverted gate. tests/links/run.sh
# documents the same trap.
if grep -qE '^(UNPAIRED|NO LABELS FOUND)' <<< "$pairing"; then
  echo "  ENTRY NUMBER NOT PAIRED WITH ITS ENTRY"
  exit 1
fi

# The bibliography's inter-entry gap must stay tied to the CV's calibrated list
# token instead of drifting back to a fixed length. The fixture raises its own
# package error on a mismatch, so a clean build is the assertion.
echo "== bibitemsep-token.tex (bibitemsep tracks CDossierRecordItemSepSkip) =="
if ! latexmk -g -lualatex -interaction=nonstopmode -halt-on-error \
    "bibitemsep-token.tex" > "bibitemsep-token.stdout" 2>&1; then
  echo "  \\bibitemsep does not track \\CDossierRecordItemSepSkip"
  echo "  (see bibitemsep-token.log)"
  exit 1
fi
echo "  bibitemsep tracks CDossierRecordItemSepSkip"

# The label/entry gap must stay tied to the shared list label token rather than
# drifting back to BibLaTeX's 2\labelsep, which lands it on the threshold where
# pdftotext's default mode splits the numbers into their own column (#199).
echo "== biblabelsep-token.tex (biblabelsep tracks CDossierListLabelSep) =="
if ! latexmk -g -lualatex -interaction=nonstopmode -halt-on-error \
    "biblabelsep-token.tex" > "biblabelsep-token.stdout" 2>&1; then
  echo "  \\biblabelsep does not track \\CDossierListLabelSep"
  echo "  (see biblabelsep-token.log)"
  exit 1
fi
echo "  biblabelsep tracks CDossierListLabelSep"

# --------------------------------------------------------------------------
# The shipped example rendered its entries (issue #319).
#
# Four tiers, cheapest first, all derived from the sources so that adding an
# entry to a database never requires editing this check. The first three prove
# Biber succeeded; only the fourth proves LaTeX put the entries on the page,
# which is the distinction issue #161 taught this repository to make.
#
# Returns 0 when the build rendered every entry its database declares, and 1
# with a diagnosis otherwise. The negative control below calls this same
# function: a control that exercised a different code path would prove nothing.
check_bibliography_render() { # <build-base-without-extension> <bib-path>
  local build="$1" bib="$2" declared rendered labels

  # Entry count from the database. The trailing comma requirement excludes
  # @string{k = {v}}, @preamble, and @comment, which declare no entry.
  if [ ! -f "$bib" ]; then
    echo "    database not found: $bib"; return 1
  fi
  declared="$(grep -cE '^[[:space:]]*@[[:alnum:]]+[[:space:]]*\{[^,{}]+,' "$bib")"
  if [ "$declared" -lt 1 ]; then
    echo "    database declares no entries: $bib"
    echo "    (a zero count would let an empty render match, so this is fatal)"
    return 1
  fi

  # Tier 1: Biber's own log.
  if [ ! -f "$build.blg" ]; then
    echo "    missing Biber log $build.blg"; return 1
  fi
  if grep -Eiq '(^| - )(WARN|ERROR) -' "$build.blg"; then
    grep -Ei '(^| - )(WARN|ERROR) -' "$build.blg" | sed 's/^/      /' | head -5
    echo "    Biber reported warnings or errors"; return 1
  fi

  # Tier 2: what Biber emitted, before any typesetting. This is the floor that
  # needs no Poppler.
  if [ ! -f "$build.bbl" ]; then
    echo "    missing $build.bbl: Biber wrote no bibliography at all"; return 1
  fi
  rendered="$(grep -c '^[[:space:]]*\\entry{' "$build.bbl")"
  if [ "$rendered" -ne "$declared" ]; then
    echo "    Biber emitted $rendered entries, database declares $declared"
    return 1
  fi

  # Tier 3: LaTeX resolved every citation.
  if grep -qE 'Citation .* undefined|Empty bibliography' "$build.log"; then
    grep -E 'Citation .* undefined|Empty bibliography' "$build.log" \
      | sed 's/^/      /' | head -5
    echo "    LaTeX reported undefined citations or an empty bibliography"
    return 1
  fi

  # Tier 4: the entries reached the page. Labels are read from the PDF's own
  # word geometry and must be exactly 1..N.
  #
  # A label is a word of the shape `N)'. The academic profile carries no phone
  # number today; one written `(555) 123-4567' would extract a word `555)' that
  # matches the shape and would break contiguity here. That fails loudly with
  # the labels listed rather than drifting silently, and the entry-pairing awk
  # above carries the same exposure, so this is consistent rather than novel.
  if ! command -v pdftotext >/dev/null 2>&1; then
    echo "    pdftotext absent: cannot confirm the entries reached the page"
    return 1
  fi
  labels="$(pdftotext -bbox "$build.pdf" - \
    | sed -n 's/.*<word [^>]*>\([0-9]\{1,\})\)<\/word>.*/\1/p' \
    | tr -d ')' | sort -n | tr '\n' ' ')"
  local expected="" i
  for (( i = 1; i <= declared; i++ )); do expected="$expected$i "; done
  if [ "$labels" != "$expected" ]; then
    echo "    rendered entry labels [$labels] do not match expected [$expected]"
    return 1
  fi

  echo "    $declared entries declared, $declared emitted, $declared rendered"
  return 0
}

echo "== examples/academic/cv-bibliography.tex (the shipped example renders its entries) =="
example_build="$root/build/examples/cv-bibliography"
mkdir -p "$root/build/examples"
# Built from the repository root, as the Makefile's own target does: the example
# writes root-relative include and bibliography paths, and any other working
# directory resolves them only by accident of the search path. -g for the same
# reason as every other build here (#312), and doubly so because `make examples'
# may have left an up-to-date PDF beside this one.
if ! (cd "$root" && latexmk -g -lualatex -interaction=nonstopmode -halt-on-error \
      -output-directory=build/examples examples/academic/cv-bibliography.tex) \
     > "$here/example-cv-bibliography.stdout" 2>&1; then
  echo "  EXAMPLE BUILD FAILED (see build/examples/cv-bibliography.log)"
  exit 1
fi
if ! check_bibliography_render "$example_build" \
     "$root/examples/academic/publications.bib"; then
  echo "  THE SHIPPED EXAMPLE LOST ITS BIBLIOGRAPHY"
  echo "  This is not a formatting difference. The example builds, exits 0, and"
  echo "  ships a PDF; the entries are simply absent. See the diagnosis above."
  exit 1
fi
echo "  the shipped example renders every entry its database declares"

# --------------------------------------------------------------------------
# Negative control (issue #319). The guard above is only worth having if it
# fires, and the failure it guards is silent by construction, so the control
# has to be committed rather than performed once by hand.
echo "== missing-bibresource.tex (negative control: the guard must fire) =="
control="missing-bibresource"
control_exit=0
latexmk -g -lualatex -interaction=nonstopmode \
  "$control.tex" > "$control.stdout" 2>&1 || control_exit=$?
if [ "$control_exit" -eq 0 ]; then
  echo "  latexmk exited 0 on an unresolvable database, as it does today"
else
  echo "  note: latexmk exited $control_exit on an unresolvable database."
  echo "  That is a stricter toolchain than the one this control was written"
  echo "  against; the guard's verdict below is still the assertion."
fi
# The database handed to the guard is the real one, not the missing one the
# control document names. Passing the missing path would short-circuit on the
# guard's own input check, proving only that it notices an absent argument;
# passing a database that declares three entries, against a build that produced
# none, makes it decide on the build's evidence instead.
#
# It fires on the first tier, and that is the correct tier: when the resource
# cannot be resolved, latexmk never runs Biber at all, so the absent .blg *is*
# the signature of this defect. The later tiers cover narrower failures — Biber
# ran but emitted fewer entries, or LaTeX did not place them — which cannot be
# reached from here. An empty-but-present database was tried as a way to reach
# them and is not silent at all: latexmk exits 12 and no PDF is produced, so it
# is not the failure this guard exists for.
if check_bibliography_render "$here/$control" "$here/publications.bib" \
   > "$control.guard" 2>&1; then
  echo "  NEGATIVE CONTROL DID NOT FIRE: the guard passed a document whose"
  echo "    bibliography cannot have rendered, so it can no longer see the"
  echo "    defect it exists for. Do not relax it."
  sed 's/^/    /' "$control.guard"
  exit 1
fi
echo "  negative control fired: the guard rejects an unresolvable database"
sed 's/^/    /' "$control.guard"
