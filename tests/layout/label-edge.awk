# label-edge.awk — does every numbered-list label start at or inside the
# text edge (#688)?
#
# Input: `pdftotext -bbox' output for one document. A label is a word of the
# shape `N)', the form CDossierPublications prints. The text edge is the
# smallest xMin of every other word: a section heading starts there, and no
# word but an intruding label sits further left. The edge is taken from the
# page rather than from the geometry, so the check holds for any paper size,
# margin, or font size the fixture chooses.
#
# Output, one tab-separated record per line:
#
#   INTRUDES <label> <label xMin> <text edge>   one per label left of the edge
#   SUMMARY  <labels seen> <text edge>          always last
#
# The caller compares the label count with the count the fixture declares, so
# a document that printed no labels cannot pass by silence.
#
# The tolerance is a thousandth of a point, below Poppler's printed precision
# and far below the one-digit intrusion (about 6pt) this check exists to see.
BEGIN { edge = ""; n = 0 }

/<word / {
  if (!match($0, /xMin="[-0-9.]+"/)) next
  x = substr($0, RSTART + 6, RLENGTH - 7) + 0
  text = $0
  sub(/^.*<word [^>]*>/, "", text)
  sub(/<\/word>.*$/, "", text)
  if (text ~ /^[0-9]+\)$/) {
    n++
    label[n] = text
    lx[n] = x
  } else if (edge == "" || x < edge) {
    edge = x
  }
}

END {
  for (i = 1; i <= n; i++)
    if (edge != "" && lx[i] < edge - 0.001)
      printf "INTRUDES\t%s\t%.3f\t%.3f\n", label[i], lx[i], edge
  printf "SUMMARY\t%d\t%s\n", n, (edge == "" ? "-" : sprintf("%.3f", edge))
}
