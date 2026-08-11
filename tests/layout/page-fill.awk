# page-fill.awk — report how full each page is, and what forced its break
# (issue #334), from a LuaLaTeX `.log` produced with `\tracingpages=1`.
#
# The keep-together assertions in run.sh check only that material stays
# *together*. Every one of them passes on a page that is half empty, and until
# this parser existed nothing in the repository measured how full a page is.
# In documents whose entire constraint is a page limit that is the other half
# of the policy, and it was the unmeasured half.
#
# `\tracingpages=1` already emits everything needed, exactly:
#
#   %% goal height=722.7, max depth=5.5
#   % t=582.65515 g=722.7 b=10000 p=-51 c=100000#
#   % t=795.74622 plus 1.0fil g=722.7 b=* p=-10000 c=*
#
# `t` is the page height accumulated at that breakpoint, `g` the goal, `b` the
# page badness, `p` the penalty at the breakpoint, and `c` the cost. A trailing
# `#` marks a candidate that became the best one so far — that is, TeX's
# `best_page_break` was updated to it. Reading the log needs no PDF tooling,
# which is the point: CI's texlive image has no poppler, and this must run
# wherever `make layout` runs.
#
# Two things about that trace are not obvious, and both decide the parse.
#
# 1. **Not every `%%` group is a page.** The page builder is exercised whenever
#    material passes through it, including the `\clearpage` at `\end{document}`
#    and a probe taken before `geometry` has set `\vsize`. On a two-page résumé
#    fixture that is five `%%` groups for two pages, and the spurious ones look
#    exactly like real ones — same goal, same candidate syntax. A group counts
#    as a page only when a shipout marker (` [1`, ` [2]`, TeX's own
#    `[<number>`) follows it before the next `%%` group begins. Every other
#    group is dropped. This parser reports what it found and never guesses; the
#    caller is expected to cross-check the count against the log's own
#    `Output written on ... (N pages)`.
#
# 2. **The break taken is the *last* `#`, not the last line.** `#` prints when
#    `c <= least_page_cost`, so it marks each update to the best breakpoint,
#    and TeX fires the output routine at whatever that last update was. The
#    line after the final `#` is therefore the candidate that was *rejected* —
#    under `\raggedbottom` the first one to overflow (`b=*`) — and its `t` minus
#    the taken `t` is the size of the atom that would not fit. That difference
#    is the number that says *why* a page is short. When the final `#` is itself
#    the last line of its group the break was forced instead, nothing was
#    rejected, and no atom is reported rather than a misleading one.
#
# Both kinds of forced break arrive as `p=-10000`, and they mean opposite
# things, so the `kind` column separates them by the one signal that does
# distinguish them — fil stretch on the taken candidate:
#
#   overflow  the page filled until the next atom did not fit. `atom` is the
#             size of that atom and is meaningful only here.
#   keep      a policy rule ended the page early. In this toolkit that is
#             `\__cdossier_components_section_need:`, the bounded section keep
#             from #333, which emits a bare `\penalty -\CDossierHeadingKeepPenalty`
#             — deliberately not `\newpage`, precisely so it contributes no fil.
#   eject     the source ended the page: `\newpage`, `\vfill`, or the
#             `\end{document}` flush, each of which contributes fil first. How
#             full such a page is says nothing about page-break policy, so a
#             fill assertion must skip it. Five committed fixtures eject, and a
#             naive threshold would flag every one of them for doing exactly
#             what their source says.
#
# Under `\raggedbottom` — which all four classes inherit, and which #342 turned
# into a standing finding — every short candidate scores `b=10000 c=100000`, so
# the cost says nothing and `p` has to be reported as its own column. It is the
# only field that attributes a hole to a specific policy rule instead of
# leaving it to be guessed at.
#
# Invoke as:
#   awk -f page-fill.awk "$base.log"
#
# Prints one tab-separated record per shipped page:
#
#   page  goal  used  fill  penalty  kind  next  atom  blank  last
#
# with every height in points, `fill` a percentage of the goal, `next` and
# `atom` set to `-` for a forced break, and `last` 1 on the final page. A short
# last page is normal and carries no information, so a caller asserting a
# minimum fill must skip it as well as every `eject` page; that is what the
# `last` and `kind` columns are for.

function reset_group() {
  goal = 0; ncand = 0; have_used = 0; used = 0
  taken_p = ""; taken_fil = 0; next_t = ""
}

# Held until END, because only END knows which page was the last one.
function record(   fill, blank, nextcol, atomcol, kind) {
  page++
  blank = goal - used
  fill = (goal > 0) ? 100 * used / goal : 0
  if (next_t == "") { nextcol = "-"; atomcol = "-" }
  else {
    nextcol = sprintf("%.2f", next_t + 0)
    atomcol = sprintf("%.2f", next_t - used)
  }
  if (taken_fil) kind = "eject"
  else if (taken_p + 0 <= -10000) kind = "keep"
  else kind = "overflow"
  return sprintf("%d\t%.2f\t%.2f\t%.1f\t%s\t%s\t%s\t%s\t%.2f", \
    page, goal, used, fill, taken_p, kind, nextcol, atomcol, blank)
}

BEGIN { page = 0; open = 0; buf = ""; nout = 0; reset_group() }

{
  line = $0
  # TeX wraps a log line at `max_print_line` wherever the character count runs
  # out, inserting nothing, so a candidate line can arrive in two pieces and
  # must be rejoined with no separator — a space would split a number in half.
  if (buf != "") { line = buf line; buf = "" }
}

line ~ /^%% goal height=/ {
  # A new page-builder page. Anything still open never shipped, so drop it.
  reset_group()
  g = line
  sub(/^%% goal height=/, "", g)
  sub(/,.*$/, "", g)
  goal = g + 0
  open = 1
  next
}

line ~ /^% t=/ {
  if (line !~ / c=/) { buf = line; next }   # wrapped: hold for the next line
  if (!open) next
  n = split(line, f, /[ \t]+/)
  t = 0; p = ""; best = 0; fil = 0; intotal = 0
  for (i = 1; i <= n; i++) {
    tok = f[i]
    if (substr(tok, 1, 2) == "t=") { t = substr(tok, 3) + 0; intotal = 1 }
    else if (substr(tok, 1, 2) == "g=") intotal = 0
    else if (intotal && tok ~ /fil/) fil = 1   # `plus 1.0fil` inside `t=...`
    else if (substr(tok, 1, 2) == "p=") p = substr(tok, 3)
    else if (substr(tok, 1, 2) == "c=") {
      c = substr(tok, 3)
      if (substr(c, length(c), 1) == "#") best = 1
    }
  }
  ncand++
  if (best) { used = t; have_used = 1; taken_p = p; taken_fil = fil; next_t = "" }
  else if (have_used && next_t == "") { next_t = t }
  next
}

# TeX's shipout marker: a space (or line start), `[`, then the page number.
# Its presence is what separates a page that was shipped from page-builder
# activity that was not.
line ~ /(^|[ ])\[[0-9]+/ {
  if (open && ncand > 0 && have_used) {
    out[++nout] = record()
    reset_group()
    open = 0
  }
}

END {
  for (i = 1; i <= nout; i++) printf "%s\t%d\n", out[i], (i == nout ? 1 : 0)
}
