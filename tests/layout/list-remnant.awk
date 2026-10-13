# list-remnant.awk — how many typeset lines the lone item of a split list
# occupies on one page (issue #564), from `pdftotext -bbox-layout` output.
#
# The list-orphan policy is stated in lines (#562): a page may not carry a
# remnant of a split list that is a single typeset line. A page carrying one
# *wrapped* item of the list is legal. Counting items cannot tell the two apart,
# so this counts the lone item's lines.
#
# Why the indent and not paragraph gaps. `-bbox-layout` emits each typeset line
# as its own `<line>` row, and a wrapped item's rows differ in where they start:
# the bullet row begins with the bullet glyph at the list's left edge, and every
# continuation row begins at the hanging indent, which is where the bullet row's
# own second word begins. So the item's lines are its bullet row plus the rows
# directly after it whose first word starts there. page-break-check.awk's
# paragraph-gap grouping, and the sensitivity constant #348 had to retune, are
# not needed.
#
# The indent is read from each item's own bullet row, never from a constant.
# `leftmargin` is derived from the bullet's width, so it moves with `fontsize`.
#
# Invoke on one page:
#   awk -v item='^• Probe' -f list-remnant.awk <<< "$page_bbox_layout"
# `item` is an ERE matched against a row's words joined by single spaces; it
# selects the bullet rows of the list under test, as in run.sh.
#
# Prints one `ITEMS<TAB>LINES<TAB>TEXT` record and exits 0. ITEMS is the number
# of rows matching `item`. When it is 1, LINES is that item's line count on this
# page and TEXT its bullet row; otherwise LINES is 0 and TEXT is empty. A lone
# item with LINES 1 is the single-line remnant the policy forbids.
#
# Exits 2 and prints nothing when the question cannot be answered, so that a
# page that was never read cannot report "no remnant" (#398): the input is not
# exactly one `-bbox-layout` page, or the lone item's bullet row has no second
# word to read the indent from.

BEGIN {
  # How far a continuation row's start may sit from the indent. Measured equal
  # to the printed precision (45.315000 both); this only absorbs rounding.
  tolerance = 0.5
  pages = 0
  rows = 0
  in_line = 0
}

# The value of attribute `name` in tag `s`. Uses index(), not match(), so it
# never clobbers RSTART for a caller.
function attr(s, name,    at, rest) {
  at = index(s, " " name "=\"")
  if (at == 0) return ""
  rest = substr(s, at + length(name) + 3)
  return substr(rest, 1, index(rest, "\"") - 1)
}

/<page[ >]/ { pages++ }

/<line[ >]/ {
  rows++
  in_line = 1
  words[rows] = 0
  text[rows] = ""
  next
}

/<\/line>/ { in_line = 0; next }

in_line && /<word[ >]/ {
  w = $0
  sub(/^[^>]*>/, "", w)
  sub(/<\/word>.*$/, "", w)
  words[rows]++
  if (words[rows] == 1) {
    first_x[rows] = attr($0, "xMin")
    first_word[rows] = w
    text[rows] = w
  } else {
    if (words[rows] == 2) second_x[rows] = attr($0, "xMin")
    text[rows] = text[rows] " " w
  }
}

function abs(v) { return v < 0 ? -v : v }

END {
  if (pages != 1) exit 2

  items = 0
  for (r = 1; r <= rows; r++)
    if (text[r] ~ item) { items++; lone = r }

  if (items != 1) {
    printf "%d\t0\t\n", items
    exit 0
  }

  if (words[lone] < 2 || second_x[lone] == "") exit 2
  indent = second_x[lone] + 0

  # A row that opens with the bullet is a new item, even at the indent: that
  # is where a nested list's bullet would sit.
  lines = 1
  for (r = lone + 1; r <= rows; r++) {
    if (first_word[r] == "•") break
    if (first_x[r] == "" || abs(first_x[r] - indent) > tolerance) break
    lines++
  }
  printf "%d\t%d\t%s\n", items, lines, text[lone]
  exit 0
}
