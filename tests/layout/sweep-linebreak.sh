#!/usr/bin/env bash
# sweep-linebreak.sh — line-breaking calibration instrument (issue #316).
#
# Forces a line-breaking parameter to each of several candidate values, rebuilds
# the corpus, and reports what each value costs and buys. This is the harness
# that #272, #310, and #309 each rebuilt privately; it is committed so the next
# calibration question starts from tested code.
#
# It is an instrument, not an assertion. Like `review-page-two` and
# `review-matrix` it carries no baseline, is not part of `make check`, and
# produces evidence a human reads. The decisions it informs are pinned
# elsewhere: by `.tlg` baselines for token values, and by the layout fixtures
# for rendered behavior.
#
# Two corpora, always reported separately and never summed, because #309 showed
# they answer different questions and the wrong one inverts the conclusion:
#
#   fixtures  tests/layout/*.tex across three body sizes and both margins.
#             Deliberately hostile content: what breaks, and at which value.
#             Its hyphen counts are NOT representative of real documents --
#             measured here the résumé family hyphenates more than any other,
#             which is an artifact of the keep-together fixtures repeating
#             filler bullets, and argues the opposite of the truth.
#   examples  examples/*/*.tex at the settings they ship with. Real documents:
#             what a user actually sees. Decide policy on this one.
#
# Six columns per arm, because counting only the benefit makes every change
# look free. Refusing a hyphen does not remove a flaw, it trades one for
# another, and only `loose` shows the other side:
#
#   overfull  lines set past the margin -- the hard failure
#   hyphens   hyphenated line ends (ASCII hyphen-minus as the last non-space
#             character of a laid-out line; en and em dashes are not counted)
#   loose     lines looser than badness 99, via \hbadness=99
#   worst     the badness of the loosest line -- ten slightly loose lines and
#             one catastrophic one are different outcomes, and `loose` alone
#             cannot tell them apart
#   third     paragraphs that reached TeX's third line-breaking pass
#             (\tracingparagraphs, counting `@emergencypass`). This is what
#             \CDossierEmergencyStretch actually spends its pool on, and #310
#             found it does not discriminate between candidate derivations --
#             the count is identical at every non-zero pool, because the pool's
#             size decides whether a paragraph *succeeds* in the third pass,
#             never whether it *enters* one.
#   pages     total pages -- a document that grows a page has been made worse
#             in a way no other column shows
#
# usage:
#   sweep-linebreak.sh [--param NAME] [--values "V1 V2 ..."] [--corpus WHICH]
#
#   --param    hyphenation      \hyphenpenalty and \exhyphenpenalty together
#              hyphenpenalty    \hyphenpenalty alone
#              exhyphenpenalty  \exhyphenpenalty alone
#              emergencystretch \emergencystretch
#              default: hyphenation
#   --values   space-separated candidates. Each is any TeX <dimen> or <integer>
#              the parameter accepts -- a plain number for a penalty, a plain
#              dimension for emergencystretch (`22pt`), or a coefficient times a
#              length register (`2.00\CDossierBodySize`, `0.040\textwidth`).
#              The second form matters for emergencystretch specifically: #310's
#              two candidate derivations both vary per body size and margin, so
#              neither can be swept as a fixed dimension -- only as the register
#              expression itself, evaluated fresh in each cell. Verified:
#              `0.040\textwidth` measures 18.79pt at fontsize=11pt/margin=normal
#              and 21.68pt at margin=narrow, matching a fraction-of-measure
#              derivation exactly; `1.50\CDossierBodySize` measures 16.5pt at
#              the same size, independent of margin. Single-quote a value
#              containing a backslash so the shell does not consume it, and
#              double the quoting through `make ... SWEEP_ARGS="..."`.
#              default: 50 200 500 1000 10000
#   --corpus   fixtures | examples | both      default: both
#
# Requirements: lualatex and pdftotext (poppler) for both corpora; pdfinfo
# (poppler) for page counts; latexmk and biber for the bibliography example,
# which is skipped with a note when they are absent.
#
# Output goes to build/linebreak-sweep/ and to stdout. Nothing is written into
# the source tree. A value containing characters unsafe in a filename (a
# backslash, most punctuation) is transliterated to `-` for its artifact name;
# `sweep-record.txt` records the value -> filename mapping so the association
# is never guessed from the slug.
set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../.." && pwd)"
output="$root/build/linebreak-sweep"
work="$(mktemp -d "${TMPDIR:-/tmp}/careerdossier-linebreak-sweep.XXXXXX")"
trap 'rm -rf "$work"' EXIT

# The rewritten sources live in $work, so both the repository root (for the
# packages and classes) and tests/layout (for the .inc files the fixture
# families share) have to be reachable by search path rather than by working
# directory.
export TEXINPUTS="$here:$root:${TEXINPUTS:-}"

param=hyphenation
values="50 200 500 1000 10000"
corpus=both

while [ "$#" -gt 0 ]; do
  case "$1" in
    --param)   param="${2:?--param needs a value}"; shift 2 ;;
    --values)  values="${2:?--values needs a value}"; shift 2 ;;
    --corpus)  corpus="${2:?--corpus needs a value}"; shift 2 ;;
    # Undocumented in the usage block above on purpose: this exists so several
    # copies of this script can run concurrently, one value each, without
    # colliding on the shared build/linebreak-sweep/ directory -- not as a
    # feature an ordinary invocation needs. A caller using it is responsible
    # for merging the results back together.
    --output)  output="${2:?--output needs a directory}"; shift 2 ;;
    -h|--help) sed -n '2,81p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
done

case "$param" in
  hyphenation|hyphenpenalty|exhyphenpenalty|emergencystretch) ;;
  *) echo "unsupported --param: $param" >&2
     echo "supported: hyphenation, hyphenpenalty, exhyphenpenalty, emergencystretch" >&2
     exit 2 ;;
esac
case "$corpus" in
  fixtures|examples|both) ;;
  *) echo "unsupported --corpus: $corpus (fixtures, examples, both)" >&2; exit 2 ;;
esac

for cmd in lualatex pdftotext pdfinfo; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "MISSING required command: $cmd" >&2; exit 1; }
done

mkdir -p "$output"
find "$output" -maxdepth 1 -type f -name '*.tsv' -delete
find "$output" -maxdepth 1 -type f -name '*.txt' -delete

# The injected preamble. \AddToHook, unlike \AtBeginDocument, is a format-level
# command and may precede \documentclass, but here it is placed immediately
# after the class line so it also works for a fixture that sets the parameter
# in its own preamble. \hbadness=99 and \tracingparagraphs=1 are reporting-only
# and never change output; \tracingonline=0 sends the trace to the log instead
# of the terminal, which is also where \hbadness's own warnings already go.
setting_for() { # value
  local v="$1"
  case "$param" in
    hyphenation)      printf '\\hyphenpenalty=%s \\exhyphenpenalty=%s' "$v" "$v" ;;
    hyphenpenalty)    printf '\\hyphenpenalty=%s' "$v" ;;
    exhyphenpenalty)  printf '\\exhyphenpenalty=%s' "$v" ;;
    emergencystretch) printf '\\setlength{\\emergencystretch}{%s}' "$v" ;;
  esac
}

# ---------------------------------------------------------------- corpus 1 --
#
# Fixtures are discovered, never listed, so adding one to tests/layout/ needs no
# edit here. Two derived rules keep that discovery honest:
#
#   - A fixture whose name already ends in -<size>pt-<margin> is one member of a
#     family generated from a shared .inc, and this sweep supplies the size and
#     margin itself. Only the first member of each family is kept, so a
#     six-fold family costs six builds rather than thirty-six. The rule is on
#     the name shape, not on a list of families.
#   - A file with no \documentclass of its own is an include or an A4 wrapper
#     around another fixture; wrappers are kept (they add paper coverage) and
#     bare includes cannot be compiled alone, so the test is for a class line
#     reachable directly or through one \input.
discover_fixtures() {
  local f base stem seen_family
  seen_family=""
  for f in "$here"/*.tex; do
    base="$(basename "$f" .tex)"
    grep -q '^\\documentclass\|^\\input{' "$f" || continue
    case "$base" in
      *-1[012]pt-normal|*-1[012]pt-narrow) stem="${base%-1[012]pt-*}" ;;
      *-1[012]pt)                          stem="${base%-1[012]pt}" ;;
      *)                                   stem="" ;;
    esac
    if [ -n "$stem" ]; then
      case " $seen_family " in
        *" $stem "*) continue ;;
        *) seen_family="$seen_family $stem" ;;
      esac
    fi
    printf '%s\n' "$base"
  done
}

sweep_fixtures() { # value -> writes rows to stdout
  local v="$1" setting base job margin size
  setting="$(setting_for "$v")"
  for margin in normal narrow; do
    for size in 10 11 12; do
      while IFS= read -r base; do
        job="${base}--${size}pt-${margin}"
        SIZE="$size" MARGIN="$margin" SETTING="$setting" awk '
          /^\\documentclass/ && !done {
            line = $0; opts = ""
            if (match(line, /\[[^]]*\]/)) {
              opts = substr(line, RSTART + 1, RLENGTH - 2)
              sub(/\[[^]]*\]/, "", line)
            }
            n = split(opts, a, ","); keep = ""
            for (i = 1; i <= n; i++) {
              gsub(/^[ \t]+|[ \t]+$/, "", a[i])
              if (a[i] == "" || a[i] ~ /^fontsize=/ || a[i] ~ /^margin=/) continue
              keep = (keep == "" ? a[i] : keep ", " a[i])
            }
            newopts = "fontsize=" ENVIRON["SIZE"] "pt, margin=" ENVIRON["MARGIN"]
            if (keep != "") newopts = keep ", " newopts
            sub(/^\\documentclass/, "\\documentclass[" newopts "]", line)
            print line
            print "\\AddToHook{begindocument/before}{\\hbadness=99 \\tracingonline=0 \\tracingparagraphs=1 " ENVIRON["SETTING"] "}"
            done = 1; next
          }
          { print }
        ' "$here/$base.tex" > "$work/$job.tex"

        # An A4 wrapper carries no \documentclass, so the injection above found
        # no anchor. Prepend it instead: the hook is format-level and legal
        # before the \input that pulls in the wrapped fixture.
        if ! grep -q 'AddToHook{begindocument/before}' "$work/$job.tex"; then
          { printf '\\AddToHook{begindocument/before}{\\hbadness=99 \\tracingonline=0 \\tracingparagraphs=1 %s}\n' "$setting"
            cat "$here/$base.tex"
          } > "$work/$job.tex"
        fi

        (cd "$here" && lualatex -output-directory="$work" -jobname="$job" \
           -interaction=nonstopmode "$work/$job.tex") >/dev/null 2>&1
        # $job, not $base: a fixture appears once per size/margin combination,
        # and only $job (e.g. `resume-two-page--11pt-narrow`) names which one a
        # given row is. A claim about *which* cell overflows -- as #310's does
        # -- cannot be checked from a TSV where six rows share one label.
        emit_row "$job" "$work/$job"
      done < <(discover_fixtures)
    done
  done
}

# ---------------------------------------------------------------- corpus 2 --
#
# Examples are discovered the same way. examples/profiles/ holds shared profile
# fragments rather than documents, and they are excluded by the same
# \documentclass test rather than by name.
discover_examples() {
  local f
  for f in "$root"/examples/*/*.tex; do
    grep -q '^\\documentclass' "$f" || continue
    printf '%s\n' "$f"
  done
}

sweep_examples() { # value
  local v="$1" setting f job
  setting="$(setting_for "$v")"
  while IFS= read -r f; do
    job="$(basename "$f" .tex)"
    SETTING="$setting" awk '
      /^\\documentclass/ && !done {
        print
        print "\\AddToHook{begindocument/before}{\\hbadness=99 \\tracingonline=0 \\tracingparagraphs=1 " ENVIRON["SETTING"] "}"
        done = 1; next
      }
      { print }
    ' "$f" > "$work/$job.tex"

    if [ "$job" = "cv-bibliography" ] && ! command -v biber >/dev/null 2>&1; then
      printf '%s\tSKIPPED-NO-BIBER\t-\t-\t-\t-\t-\n' "$job"
      continue
    fi
    # From the repository root, as the Makefile's example targets do: the
    # examples write their includes and bibliography as root-relative paths
    # (`\input{examples/profiles/...}`), so any other working directory only
    # resolves them by accident of the search path.
    if command -v latexmk >/dev/null 2>&1; then
      (cd "$root" && latexmk -lualatex -interaction=nonstopmode \
         -halt-on-error -output-directory="$work" -jobname="$job" "$work/$job.tex") \
        >/dev/null 2>&1
    else
      (cd "$root" && lualatex -output-directory="$work" -jobname="$job" \
         -interaction=nonstopmode "$work/$job.tex" && \
       lualatex -output-directory="$work" -jobname="$job" \
         -interaction=nonstopmode "$work/$job.tex") >/dev/null 2>&1
    fi
    emit_row "$job" "$work/$job"
  done < <(discover_examples)
}

emit_row() { # label jobpath
  local label="$1" jp="$2" over hy loose pages worst third
  if [ ! -f "$jp.pdf" ] || [ ! -f "$jp.log" ]; then
    printf '%s\tBUILD-FAILED\t-\t-\t-\t-\t-\n' "$label"; return
  fi
  over="$(grep -cE 'Overfull \\hbox' "$jp.log" || true)"
  loose="$(grep -cE 'Underfull \\hbox \(badness' "$jp.log" || true)"
  pages="$(pdfinfo "$jp.pdf" 2>/dev/null | awk '/^Pages:/{print $2}')"
  hy="$(pdftotext -layout -enc UTF-8 "$jp.pdf" - 2>/dev/null \
        | sed 's/[[:space:]]*$//' | grep -c -- '-$' || true)"
  worst="$(grep -oE 'Underfull \\hbox \(badness [0-9]+' "$jp.log" \
           | grep -oE '[0-9]+$' | sort -n | tail -1)"
  third="$(grep -c '@emergencypass' "$jp.log" || true)"
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$label" "$over" "$hy" "$loose" "${worst:-0}" "$third" "${pages:-0}"
}

summarize() { # label file
  LABEL="$1" awk -F'\t' '
    $2 == "BUILD-FAILED" { failed++; next }
    $2 == "SKIPPED-NO-BIBER" { skipped++; next }
    { over += $2; hy += $3; loose += $4; third += $6; pages += $7; n++
      if ($5 + 0 > worst) worst = $5 + 0 }
    END {
      printf "%-24s %8d %10d %8d %8d %8d %8d %7d", \
        ENVIRON["LABEL"], over, hy, loose, worst, third, pages, n
      if (failed)  printf "  (%d build failure(s))", failed
      if (skipped) printf "  (%d skipped)", skipped
      printf "\n"
    }
  ' "$2"
}

echo "Line-breaking sweep: --param $param --values \"$values\" --corpus $corpus"
echo

for which in fixtures examples; do
  case "$corpus" in
    both) ;;
    "$which") ;;
    *) continue ;;
  esac

  echo "== corpus: $which =="
  case "$which" in
    fixtures) echo "   tests/layout, 3 body sizes x 2 margins. Stress content:" \
                   "read for what breaks," ;;
    examples) echo "   examples/, as shipped. Real documents: read for policy," ;;
  esac
  echo "   never summed with the other corpus."
  echo
  printf '%-24s %8s %10s %8s %8s %8s %8s %7s\n' \
    value overfull hyphens loose worst third pages docs
  for v in $values; do
    # A value carrying a backslash or other filename-unsafe character (any
    # TeX-derivation value does) cannot be embedded in a path raw. Transliterate
    # it to `-`; the mapping below is what lets a reader recover the original.
    slug="$(printf '%s' "$v" | tr -c 'A-Za-z0-9._-' '-')"
    f="$output/$which-$param-$slug.tsv"
    if [ "$which" = fixtures ]; then sweep_fixtures "$v" > "$f"
    else                             sweep_examples "$v" > "$f"; fi
    summarize "$v" "$f"
    printf '%s\t%s\n' "$v" "$(basename "$f")" >> "$output/.value-map.$which.tsv"
  done
  echo
done

{
  echo "# CareerDossierTeX line-breaking sweep (issue #316)"
  echo "commit: $(git -C "$root" rev-parse HEAD 2>/dev/null || echo unavailable)"
  echo "param: $param"
  echo "values: $values"
  echo "corpus: $corpus"
  echo
  echo "Per-document rows are in the .tsv files beside this record, one per"
  echo "corpus and value, with columns:"
  echo "  document  overfull  hyphens  loose  worst  third  pages"
  echo
  echo "A fixture-corpus document is named <fixture>--<size>pt-<margin>, which is"
  echo "what makes a specific overflowing cell identifiable rather than merely"
  echo "countable."
  echo
  echo "Read the two corpora separately. Stress-fixture hyphen counts are not"
  echo "representative of real documents; decide policy on the examples."
  echo
  echo "Value -> artifact filename (a value is sanitised for the filesystem;"
  echo "this is the only record of which file holds which value):"
  for which in fixtures examples; do
    [ -f "$output/.value-map.$which.tsv" ] || continue
    echo "  [$which]"
    sed 's/^/    /' "$output/.value-map.$which.tsv"
  done
} > "$output/sweep-record.txt"
rm -f "$output"/.value-map.*.tsv

echo "Artifacts: $output"
