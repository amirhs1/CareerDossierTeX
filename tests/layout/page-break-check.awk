# page-break-check.awk — detect typographic page-break defects (issue #171)
# from `pdftotext -bbox` output for a whole PDF.
#
# Reports two kinds of finding:
#
#   BROKEN — the last line of a page ends with a hyphen, so a hyphenated word
#            is split across the page break (`\brokenpenalty`).
#   CLUB / WIDOW — a single line of a paragraph is stranded alone at the foot
#            of a page or the head of the next (`\clubpenalty`,
#            `\widowpenalty`).
#
# Why coordinates rather than text. Both checks were first written against
# `pdftotext`'s plain text output and both were wrong there:
#
#   - For BROKEN, the page's folio (`Page N of M`) and blank lines sit between
#     the last body line and the form-feed page marker, so no text-adjacency
#     test to the form feed can see the hyphen at all. (A `grep -E '\f'`
#     formulation is doubly unsafe: GNU grep reads `\f` in an ERE as a literal
#     `f`, which then matches any hyphen followed by `f` anywhere in the
#     document — an ordinary compound word like "after-the-fact" is enough.)
#   - For CLUB/WIDOW, line width does not identify a paragraph edge: a
#     paragraph's final line can coincidentally run nearly as long as a full
#     continuation line, and trailing punctuation marks the end of a
#     *sentence*, not of a paragraph.
#
# So this reads per-word coordinates, groups words into visual lines by
# y-position, finds each page's modal line-to-line gap (its normal leading),
# and treats a notably larger gap as a real paragraph boundary — the actual
# geometric signal `\parskip` produces. That yields, per page, how many lines
# belong to its first and last paragraph.
#
# Furniture handling differs per check, deliberately:
#
#   - Both exclude the `Page N of M` folio and the running header, which are
#     page furniture rather than body text.
#   - BROKEN keeps bulleted list lines: a bullet's own text can be hyphenated
#     across the break, and in this corpus that is exactly where it happens.
#   - CLUB/WIDOW excludes them: list boundaries are already governed by
#     CDossierListOrphanPenalty and asserted by the *keeptogether* fixtures,
#     and a bullet's naturally short last line is not a prose remnant.
#
# Invoke as:
#   pdftotext -bbox "$pdf" - \
#     | awk -v furniture="$label" -v prose=1 -f page-break-check.awk
# `furniture` is the running-header label for the fixture (see run.sh).
# `prose=1` additionally enables the CLUB/WIDOW checks, which apply only to
# the continuous-prose families; BROKEN is always checked. Reading order
# within a page is trusted as top-to-bottom (verified against this project's
# running-header and folio placement).
#
# Prints one `TYPE<TAB>PAGE<TAB>TEXT` line per finding; prints nothing when
# the document has none.

# How much larger than the leading a gap must be to count as a paragraph
# boundary. This is the whole sensitivity of the CLUB/WIDOW check, and it was
# wrong until issue #348: at 1.35 no ordinary paragraph boundary in this corpus
# was ever recognized, so the check reported "no widow or club line" on every
# prose fixture by never looking.
#
# The signal is `\parskip`, which both prose families set to 0.25 x the body
# leading, so a paragraph boundary measures 1.25-1.29 x the modal gap against
# 1.0 x for ordinary leading. Measured on the committed fixtures at class
# defaults: 18.06pt against a 14pt modal, or 1.290 x, in both families. 1.15
# sits between the two populations with margin on each side.
#
# Do not raise this without re-running the negative control in run.sh, which
# exists because this exact value went unowned: at 1.35 the control's declared
# CLUB is not reported, and the whole check silently passes on everything.
BEGIN { PARA_GAP = 1.15 }

function is_folio_or_header(t) {
  if (t ~ /^Page [0-9]+ of [0-9]+$/) return 1
  if (furniture != "" && index(t, furniture) > 0) return 1
  return 0
}

function is_bullet(t) {
  return (index(t, "•") == 1)
}

function commit_line() {
  if (curtext != "" && !is_folio_or_header(curtext)) {
    # Every body line, bullets included — used for the BROKEN check.
    m++
    alltxt[m] = curtext
    # Prose-only lines — used for the CLUB/WIDOW paragraph segmentation.
    if (!is_bullet(curtext)) {
      n++
      ytab[n] = cury
      txt[n] = curtext
    }
  }
  curtext = ""
}

function process_page(   i, g, key, modal, bestcount, gapfreq, para, firstlines, lastlines) {
  if (m > 0) page_last_any[page] = alltxt[m]
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
    if (g > modal * PARA_GAP) para[i] = para[i-1] + 1
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

/<page / { page++; n = 0; m = 0; curtext = ""; have_cur = 0 }

/<word / {
  # yMin is the 4th quoted attribute value. The word's own text is taken as
  # everything between the first ">" and "</word>" rather than as a later
  # quote-delimited field, so a double quote inside the text cannot shift it.
  split($0, f, "\"")
  y = f[4] + 0
  t = $0
  sub(/^[^>]*>/, "", t)
  sub(/<\/word>.*$/, "", t)
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

    # BROKEN: the page's final body line ends with a hyphen. U+002D is what
    # the TeX Gyre fonts' hyphen extracts as; U+2010 is checked as well so a
    # font change cannot silently disable the assertion.
    anyt = page_last_any[p]
    if (anyt != "" && (anyt ~ /-$/ || anyt ~ /‐$/)) {
      print "BROKEN\t" p "\t" anyt
    }

    if (prose != 1) continue

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
