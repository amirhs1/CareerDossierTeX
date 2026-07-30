# widow-club-check.awk — detect a single-line paragraph remnant at a page
# boundary (issue #171) from `pdftotext -bbox` output for a whole PDF.
#
# Text width is not a reliable signal for this: a paragraph's final line can
# coincidentally run nearly as long as a full continuation line, and a
# continuation line can legitimately run short when the line-breaking
# algorithm accepts a looser fit. Instead, this groups words into visual
# lines by y-position, finds each page's modal line-to-line gap (its normal
# leading), and treats any notably larger gap as a paragraph boundary. That
# yields, for each page, how many lines belong to its first and last
# paragraph. A page ending on a lone line whose text does not end in
# sentence punctuation (so the paragraph is provably unfinished) is a club
# line; if the next page's first paragraph is then also a lone line, that is
# the matching widow line.
#
# Invoke as:
#   pdftotext -bbox "$pdf" - | awk -v furniture="$label" -f widow-club-check.awk
# `furniture` is the running-header label for the fixture (see run.sh); the
# `Page N of M` folio and bulleted list items are always excluded. Reading
# order within a page is trusted as top-to-bottom (verified against this
# project's running-header and folio placement).
#
# Prints one `TYPE\tPAGE\tTEXT` line per remnant found; prints nothing when
# the document has none.

function is_furniture(t) {
  if (t ~ /^Page [0-9]+ of [0-9]+$/) return 1
  if (furniture != "" && index(t, furniture) > 0) return 1
  if (index(t, "•") == 1) return 1
  return 0
}

function commit_line() {
  if (curtext != "" && !is_furniture(curtext)) {
    n++
    ytab[n] = cury
    txt[n] = curtext
  }
  curtext = ""
}

function process_page(   i, g, key, modal, bestcount, gapfreq, para, firstlines, lastlines) {
  if (n == 0) return
  if (n == 1) {
    page_first_lines[page] = 1; page_first_text[page] = txt[1]
    page_last_lines[page] = 1; page_last_text[page] = txt[1]
    return
  }
  for (i = 2; i <= n; i++) {
    g = ytab[i] - ytab[i-1]
    key = int(g + 0.5); if (key < 1) key = 1
    gapfreq[key]++
  }
  modal = 0; bestcount = 0
  for (key in gapfreq) if (gapfreq[key] > bestcount) { bestcount = gapfreq[key]; modal = key }
  if (modal == 0) modal = 1
  para[1] = 1
  for (i = 2; i <= n; i++) {
    g = ytab[i] - ytab[i-1]
    if (g > modal * 1.35) para[i] = para[i-1] + 1
    else para[i] = para[i-1]
  }
  firstlines = 0
  for (i = 1; i <= n; i++) { if (para[i] != para[1]) break; firstlines++ }
  lastlines = 0
  for (i = n; i >= 1; i--) { if (para[i] != para[n]) break; lastlines++ }
  page_first_lines[page] = firstlines
  page_first_text[page] = txt[1]
  page_last_lines[page] = lastlines
  page_last_text[page] = txt[n]
}

/<page / { page++; n = 0; curtext = ""; have_cur = 0 }

/<word / {
  split($0, f, "\"")
  y = f[4] + 0
  t = f[9]
  sub(/^>/, "", t)
  sub(/<\/word>.*/, "", t)
  key = int(y + 0.5)
  if (have_cur && key == curkey) {
    curtext = curtext " " t
  } else {
    commit_line()
    curkey = key
    curtext = t
    cury = y
    have_cur = 1
  }
}

/<\/page>/ {
  commit_line()
  process_page()
}

END {
  for (p = 1; p < page; p++) {
    q = p + 1
    lastn = page_last_lines[p]; lastt = page_last_text[p]
    firstn = page_first_lines[q]; firstt = page_first_text[q]
    lastchar = substr(lastt, length(lastt), 1)
    mid_sentence = (index(".!?:;", lastchar) == 0)
    if (lastn == 1 && mid_sentence) {
      print "CLUB\t" p "\t" lastt
    }
    if (firstn == 1 && mid_sentence) {
      print "WIDOW\t" q "\t" firstt
    }
  }
}
