#!/usr/bin/env bash
# run-list-remnant.sh — the committed negative controls for
# tests/layout/list-remnant.awk (issue #564).
#
# The layout suite's ORPHANED BULLET assertion is stated in lines: a page may
# not carry a single-line remnant of a split list, and a page carrying one
# wrapped item is legal. list-remnant.awk counts the lone item's lines from
# where its rows start. The layout fixtures exercise it only at the geometry the
# guards let through, so a wrapped remnant passing proves nothing about a
# single-line one firing, and the single-line control fires only while someone
# frees the guards by hand. These controls drive the script over synthetic
# `pdftotext -bbox-layout` pages instead: the remnant it must reject, the one it
# must accept, an indent other than the one the fixtures happen to print, and
# the pages it must refuse to judge.
#
# Nothing is compiled, so this runs in the `lint` slot and on the TeX-free CI
# lint runner.

set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../.." && pwd)"
script="$root/tests/layout/list-remnant.awk"
fails=0

# shellcheck source=tests/lib/text.sh
. "$root/tests/lib/text.sh"

# page <row>... — one `-bbox-layout` page. Each row is its words, separated by
# spaces, each word written `xMin=text`; the shape and attribute order are
# pdftotext's.
page() {
  local row word
  printf '  <page width="612.000000" height="792.000000">\n    <flow>\n'
  printf '      <block xMin="36.000000" yMin="0" xMax="576.000000" yMax="792">\n'
  for row in "$@"; do
    printf '        <line xMin="0" yMin="0" xMax="0" yMax="0">\n'
    for word in $row; do
      printf '          <word xMin="%s" yMin="0" xMax="0" yMax="0">%s</word>\n' \
        "${word%%=*}" "${word#*=}"
    done
    printf '        </line>\n'
  done
  printf '      </block>\n    </flow>\n  </page>\n'
}

# expect <name> <item ere> <expected record or "unchecked"> <input>
#
# Compares ITEMS<TAB>LINES; the item's text is not part of the verdict.
expect() {
  local out rc got
  out="$(awk -v item="$2" -f "$script" <<< "$4")"
  rc="$?"
  if [ "$3" = unchecked ]; then
    if [ "$rc" -ne 0 ] && [ -z "$out" ]; then
      printf '  ok: %s\n' "$1"
    else
      printf '  FAIL: %s: expected no verdict, got status %s and %s\n' \
        "$1" "$rc" "${out:-nothing}"
      fails=$((fails + 1))
    fi
    return
  fi
  got="$(printf '%s' "$out" | cut -f1,2)"
  if [ "$rc" -eq 0 ] && [ "$got" = "$3" ]; then
    printf '  ok: %s\n' "$1"
  else
    printf '  FAIL: %s: expected %s, got status %s and %s\n' \
      "$1" "$(printf '%s' "$3" | tr '\t' ' ')" "$rc" \
      "$(printf '%s' "${out:-nothing}" | tr '\t' ' ')"
    fails=$((fails + 1))
  fi
}

header='254.246=Grace 281.109=Hopper'
folio='283.203=Page 306.363=2'
tab='	'

printf '== control 1: the single-line remnant is reported as one line ==\n'
expect "a lone one-line item" '^•' "1${tab}1" \
  "$(page "$header" '36.000=• 45.315=Probe 70.882=item' "$folio")"
expect "a lone one-line item at the foot of a page" '^• Probe' "1${tab}1" \
  "$(page '36.000=• 45.315=Filler 80.000=line' \
          '36.000=Reporting 86.005=Platform' \
          '36.000=• 45.315=Probe 70.882=item' "$folio")"

printf '\n== control 2: a wrapped remnant counts its continuation lines ==\n'
expect "a lone two-line item" '^•' "1${tab}2" \
  "$(page "$header" '36.000=• 45.315=Probe 70.882=item' \
          '45.315=legal 69.140=under' "$folio")"
expect "a lone three-line item" '^•' "1${tab}3" \
  "$(page "$header" '36.000=• 45.315=Probe 70.882=item' \
          '45.315=tall 62.148=enough' '45.315=list 61.293=has' "$folio")"

printf '\n== control 3: the indent is read from the item, not assumed ==\n'
# A different fontsize moves the hanging indent. Read from the item, 52.700 is
# the indent; a check that assumed the 11pt value would count the wrong row.
expect "an indent other than the 11pt one" '^•' "1${tab}2" \
  "$(page "$header" '40.000=• 52.700=Probe 80.000=item' \
          '52.700=legal 76.000=under' "$folio")"
expect "a row at the 11pt indent is not this item's continuation" '^•' \
  "1${tab}1" \
  "$(page "$header" '40.000=• 52.700=Probe 80.000=item' \
          '45.315=Other 70.000=text' "$folio")"

printf '\n== control 4: what follows the item ends it ==\n'
expect "a nested bullet at the indent is a new item" '^• Outer' "1${tab}1" \
  "$(page '36.000=• 45.315=Outer 70.000=item' \
          '45.315=• 54.630=Inner 80.000=item' "$folio")"
expect "two items of the list are not a remnant" '^•' "2${tab}0" \
  "$(page '36.000=• 45.315=Probe 70.882=one' \
          '36.000=• 45.315=Probe 70.882=two' "$folio")"
expect "a page carrying none of the list" '^• Probe' "0${tab}0" \
  "$(page '36.000=• 45.315=Filler 80.000=line' "$folio")"

printf '\n== control 5: a page that was not read gets no verdict ==\n'
# The #398 shape: "could not measure" must never read as "no remnant".
expect "the unavailable-text sentinel" '^•' unchecked "$CDTEXT_UNAVAILABLE"
expect "empty input" '^•' unchecked ""
expect "two pages where one was asked for" '^•' unchecked \
  "$(page '36.000=• 45.315=Probe 70.882=item')
$(page "$folio")"
expect "a bullet row with no second word to read the indent from" '^•' \
  unchecked "$(page '36.000=•' '45.315=Probe 70.882=item' "$folio")"

printf '\n'
if [ "$fails" -ne 0 ]; then
  printf 'list remnant: %d control(s) FAILED.\n' "$fails"
  exit 1
fi
printf 'list remnant: all controls passed.\n'
exit 0
