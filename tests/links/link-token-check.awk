# link-token-check.awk — copy-paste integrity of URLs and e-mail addresses
# (issue #294) decided from `pdftotext -bbox` output for a whole PDF.
#
# A URL or an e-mail address must survive copy-and-paste out of the PDF as one
# unbroken token. What decides that is not the character sequence — which is
# always correct — but the *typesetting*: Poppler starts a new `<word>` wherever
# an intra-word gap exceeds 0.1 em, so a URL whose breakpoints were stretched by
# a justified line extracts as `https : / / example . invalid /`. The rendered
# page looks unremarkable, which is why this needs its own checker.
#
# Why coordinates rather than extracted text. In plain `pdftotext` output a
# legitimate line wrap and a split token are indistinguishable: both put
# whitespace between the pieces. The bounding boxes tell them apart — pieces on
# *different* baselines are a wrap, pieces sharing *one* baseline are the
# defect.
#
# Each fixture declares the tokens that must stay atomic, one per line, in a
# companion `<fixture>.tokens` file (run.sh extracts these from the fixture's
# own `% LINKTOKEN:` comments, so the expectation lives beside the source that
# produces it). For every occurrence of a declared token this reports:
#
#   SPLIT    — the token is spelled by two or more words sharing one baseline.
#              This is the defect: copy-and-paste yields embedded spaces.
#   MISSING  — the token does not appear in the document at all. Reported so a
#              fixture that stops rendering its link fails loudly instead of
#              passing vacuously.
#
# and, for a token that is present and intact everywhere,
#
#   VERIFIED — with the number of occurrences and how many of them wrapped
#              across a line break (a wrap is legitimate and is *not* a
#              finding; it is reported so a fixture meant to force one can be
#              seen to have done so).
#
# Invoke as:
#   pdftotext -bbox "$pdf" - | awk -v tokfile="$base.tokens" -f link-token-check.awk
#
# Prints one `TYPE<TAB>...` record per declared token (plus one per SPLIT
# occurrence). Reading order within a page is trusted as content-stream order,
# as tests/layout/page-break-check.awk does.

function unescape(s) {
  gsub(/&lt;/, "<", s); gsub(/&gt;/, ">", s)
  gsub(/&quot;/, "\"", s); gsub(/&apos;/, "'", s)
  gsub(/&amp;/, "\\&", s)   # last, so an escaped entity is not unescaped twice
  return s
}

# Baseline bucket for a word's yMin. Words typeset on one baseline report the
# same yMin to the last decimal when they share a font, but a line mixing sizes
# (the contact line's small text beside a symbol, a bibliography's bold label)
# differs by a fraction of a point on the very same baseline — so bucket within
# a tolerance rather than on exact equality. The tolerance stays far below the
# leading, which is what separates two real lines.
function baseline_of(y,   b) {
  for (b = 1; b <= nb; b++)
    if (y - bys[b] < tol && bys[b] - y < tol) return b
  bys[++nb] = y
  return nb
}

# No array is cleared between pages, and nothing needs to be: `nw` and `nb`
# reset to zero, every per-word and per-baseline array is only ever read up to
# the current count, and the line-edge arrays are keyed by page as well as
# baseline. Whole-array `delete` is a widespread extension rather than POSIX,
# and this runs under whichever awk the machine has — the one-true-awk locally,
# Debian's in CI.
function reset_page() {
  nw = 0; nb = 0
}

function process_page(   i, j, k, t, lkey, joined, pos, p, abs, last, wi, wj, ok, split_here, wrapped, pieces) {
  if (nw == 0) return
  joined = ""
  for (i = 1; i <= nw; i++) {
    wstart[i] = length(joined) + 1
    joined = joined wtext[i]
    wend[i] = length(joined)
    lkey = page "," wline[i]
    if (!(lkey in linefirst)) linefirst[lkey] = i
    linelast[lkey] = i
  }

  for (t = 1; t <= nt; t++) {
    pos = 1
    while ((p = index(substr(joined, pos), tok[t])) > 0) {
      abs = pos + p - 1
      last = abs + length(tok[t]) - 1
      wi = 0; wj = 0
      for (i = 1; i <= nw; i++) {
        if (wstart[i] <= abs && abs <= wend[i]) wi = i
        if (wstart[i] <= last && last <= wend[i]) { wj = i; break }
      }
      pos = abs + 1
      if (wi == 0 || wj == 0) continue

      # One `<word>` spells the whole token: atomic, nothing more to check.
      if (wi == wj) { found[t]++; continue }

      # Several words spell it. Each adjacent pair is either the defect (same
      # baseline) or a line wrap — and a wrap is only credible when the pieces
      # sit at the very edges of their lines. A pair that satisfies neither is
      # an accidental match across unrelated page content, so the occurrence is
      # discarded rather than reported either way.
      split_here = 0; wrapped = 0; ok = 1; pieces = wtext[wi]
      for (k = wi; k < wj; k++) {
        pieces = pieces " | " wtext[k+1]
        if (wline[k] == wline[k+1]) split_here = 1
        else if (linelast[page "," wline[k]] == k \
                 && linefirst[page "," wline[k+1]] == k + 1) wrapped = 1
        else { ok = 0; break }
      }
      if (!ok) continue
      found[t]++
      if (split_here) {
        split_count[t]++
        print "SPLIT\t" page "\t" tok[t] "\t" pieces
      } else if (wrapped) {
        wrap_count[t]++
      }
    }
  }
}

BEGIN {
  tol = 1.0
  if (tokfile == "") { print "ERROR\tno tokfile given"; exit 1 }
  while ((getline line < tokfile) > 0) {
    sub(/^[ \t]+/, "", line); sub(/[ \t]+$/, "", line)
    if (line != "") tok[++nt] = line
  }
  close(tokfile)
  if (nt == 0) { print "ERROR\tno tokens declared in " tokfile; exit 1 }
}

/<page / { if (page > 0) process_page(); page++; reset_page() }

/<word / {
  # yMin is the 4th quoted attribute value. The text is everything between the
  # first ">" and "</word>", not a later quote-delimited field, so a double
  # quote inside the text cannot shift it.
  split($0, f, "\"")
  y = f[4] + 0
  t = $0
  sub(/^[^>]*>/, "", t)
  sub(/<\/word>.*$/, "", t)
  nw++
  wtext[nw] = unescape(t)
  wline[nw] = baseline_of(y)
}

END {
  process_page()
  for (t = 1; t <= nt; t++) {
    if (found[t] + 0 == 0) print "MISSING\t" tok[t]
    else if (split_count[t] + 0 == 0)
      print "VERIFIED\t" tok[t] "\t" found[t] " occurrence(s), " \
            (wrap_count[t] + 0) " wrapped across a line break"
  }
}
