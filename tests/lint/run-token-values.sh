#!/usr/bin/env bash
# run-token-values.sh — the documented calibrated values (issue #487)
#
# Three surfaces state the same calibrated numbers, and only the first ships:
#
#   careerdossier-tokens.sty   the declarations that ship
#   docs/ARCHITECTURE.md       38 valued rows across three tables
#   doc/careerdossier.tex      the user-facing `fontsize' size table
#
# A retune changes the first and nothing forces the other two to follow. That
# is the failure mode #185 already cost this project once: after the v0.7.0
# retune, ten sentences were left stale across three documents, one of them
# documenting a recipe that restored half the spacing it claimed to remove.
#
# Nothing caught it before this file. run-manual-names.sh (#468, #263) checks
# that documented *names* exist in the Work and that no private name is
# published; it never compares a number. Compiling the manual does not help
# either -- a manual stating `11 / 12 / 13 pt' for a token that now ships
# `12 / 13 / 14' typesets perfectly and reads as authoritative. LaTeX never
# sees these numbers as claims about the source; they are digits in a document.
#
# So this lint reads both sides as text and asserts four things:
#
#   1. Every ratio the vertical-rhythm table states equals the ratio
#      careerdossier-tokens.sty declares for that token, and the two sides name
#      the same set of tokens -- a row for a token the source dropped, or a
#      token the table never gained a row for, both fail.
#   2. Every resolved point value in that table equals ratio x body baseline
#      for its `fontsize'.
#   3. Every type-scale size/leading pair, and every derived-metric row, equals
#      what the source declares.
#   4. The manual's `fontsize' table states the sizes the source declares.
#
# The ratio column of the *type scale* is deliberately not checked. That table
# says so itself -- "the ratio column is design intent and does not ship" --
# and it does not resolve: 19/10 is 1.90 but 21/11 is 1.909 and 23/12 is
# 1.9167. Only the point columns are a claim about the source. The vertical
# rhythm's ratio column is the opposite: it is the literal argument to
# \__cdossier_tokens_set_skip:Nn, so it is checked exactly.
#
# The manual's rows carry prose role labels rather than token names, so the
# role-to-token map is declared explicitly below and a row label the map does
# not know fails. That is the trap #468 hit from the other side: a match that
# does not cover both sides passes by matching nothing.
#
# The lint parses text and arithmetic; it runs no LaTeX and needs no TeX
# installation. Requirements: bash and awk. Run from anywhere. It ends by
# running itself against tests/lint/fixtures/tokenfixture-*, one per verdict,
# so a lint that had stopped detecting anything fails here rather than passing
# everything.
#
# Portability, as in the sibling lints: local `grep' is ugrep and CI's is GNU
# grep, local `awk' is one-true-awk and CI's is gawk or mawk. A brace is
# written `[{]' rather than `\{'. Run under bash, not zsh.
set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../.." && pwd)"

fixtures="$here/fixtures"

source_file="$root/careerdossier-tokens.sty"
architecture="$root/docs/ARCHITECTURE.md"
manual="$root/doc/careerdossier.tex"

# Comparisons are decimal arithmetic on values TeX resolves in scaled points
# (1/65536 pt), and the tables round for display. Half a thousandth of a point
# is far below anything a reader or a renderer can distinguish, and far above
# the representation error of the products involved.
tolerance=0.0005

# The manual's table names roles, not tokens. Declared here, and an unmapped
# row is a failure rather than a skip.
manual_roles="Name=CDossierSizeName
Statement title=CDossierSizeDocumentTitle
Headline, subtitle=CDossierSizeHeadline
Section heading=CDossierSizeSection
Entry title, body text, bullets, dates=CDossierSizeBody
Contact line=CDossierSizeSmall
Running header, folio=CDossierSizeFurniture"

# ---------------------------------------------------------------------------
# The source side.
# ---------------------------------------------------------------------------

# Every calibrated value careerdossier-tokens.sty declares, as one flat record
# stream. Five record kinds, each `kind key... value...':
#
#   bodysize  <fontsize> <pt>
#   leading   <fontsize> <pt>
#   furniture <fontsize> <pt>
#   scale     <fontsize> <selector> <size> <leading>
#   ratio     <token> <ratio>
#   derived   <token> <factor> <basis>
#
# The `fontsize' blocks are the arms of \__cdossier_tokens_resolve:'s
# \str_case:Vn, each opening with `{ 10pt }' alone on its line. The margin
# \str_case: below it writes both arms on one line, so it cannot be mistaken
# for one.
source_values() {
  awk '
    /^[[:space:]]*[{][[:space:]]*(10|11|12)pt[[:space:]]*[}][[:space:]]*$/ {
      line = $0; sub(/[^0-9]*/, "", line); sub(/pt.*/, "", line)
      cur = line "pt"; pending = ""; next
    }

    match($0, /\\dim_set:Nn[[:space:]]+\\CDossierBodySize[[:space:]]*[{][[:space:]]*[0-9.]+pt[[:space:]]*[}]/) {
      v = $0; sub(/.*CDossierBodySize[^0-9]*/, "", v); sub(/pt.*/, "", v)
      print "bodysize", cur, v; pending = ""; next
    }
    match($0, /\\dim_set:Nn[[:space:]]+\\CDossierBodyLeading[[:space:]]*[{][[:space:]]*[0-9.]+pt[[:space:]]*[}]/) {
      v = $0; sub(/.*CDossierBodyLeading[^0-9]*/, "", v); sub(/pt.*/, "", v)
      print "leading", cur, v; pending = ""; next
    }
    match($0, /\\dim_set:Nn[[:space:]]+\\CDossierFurnitureLeading[[:space:]]*[{][[:space:]]*[0-9.]+pt[[:space:]]*[}]/) {
      v = $0; sub(/.*CDossierFurnitureLeading[^0-9]*/, "", v); sub(/pt.*/, "", v)
      print "furniture", cur, v; pending = ""; next
    }

    # \__cdossier_tokens_set_size_command:Nnn wraps its arguments onto the
    # following line, which is where the selector and its two dimensions are.
    match($0, /^[[:space:]]*\\CDossierSize[A-Za-z]+[[:space:]]*[{][[:space:]]*[0-9.]+pt[[:space:]]*[}][[:space:]]*[{][[:space:]]*[0-9.]+pt[[:space:]]*[}]/) {
      line = $0
      match(line, /CDossierSize[A-Za-z]+/)
      nm = substr(line, RSTART, RLENGTH)
      rest = substr(line, RSTART + RLENGTH)
      n = split(rest, field, /[{}]/)
      count = 0
      for (i = 1; i <= n; i++) {
        g = field[i]; gsub(/[[:space:]]/, "", g)
        if (g ~ /^[0-9.]+pt$/) {
          sub(/pt$/, "", g); count++
          if (count == 1) size = g; else if (count == 2) leading = g
        }
      }
      if (count >= 2) print "scale", cur, nm, size, leading
      pending = ""; next
    }

    match($0, /\\__cdossier_tokens_set_skip:Nn[[:space:]]+\\CDossier[A-Za-z]+[[:space:]]*[{][[:space:]]*[0-9.]+[[:space:]]*[}]/) {
      line = $0
      match(line, /CDossier[A-Za-z]+/)
      nm = substr(line, RSTART, RLENGTH)
      rest = substr(line, RSTART + RLENGTH)
      sub(/[^0-9.]*/, "", rest); sub(/[^0-9.].*/, "", rest)
      print "ratio", nm, rest; pending = ""; next
    }

    # A derived metric spans three lines: the \dim_set:Nn naming the token,
    # then \fp_to_dim:n, then the factor and its basis.
    match($0, /\\dim_set:Nn[[:space:]]+\\CDossier(RuleThickness|ListLabelSep|EmergencyStretch)[[:space:]]*$/) {
      line = $0
      match(line, /CDossier[A-Za-z]+/)
      pending = substr(line, RSTART, RLENGTH); next
    }
    pending != "" && match($0, /[0-9.]+[[:space:]]*\*[[:space:]]*\\dim_to_fp:n[[:space:]]*[{][[:space:]]*\\CDossier[A-Za-z]+/) {
      line = substr($0, RSTART, RLENGTH)
      factor = line; sub(/[^0-9.].*/, "", factor)
      match(line, /CDossier[A-Za-z]+$/)
      basis = substr(line, RSTART, RLENGTH)
      print "derived", pending, factor, basis
      pending = ""; next
    }
  ' "$1"
}

# ---------------------------------------------------------------------------
# The documentation side.
# ---------------------------------------------------------------------------

# The first Markdown table under a given `#### ' heading, header row included,
# with the alignment row dropped. Empty output means the heading or its table
# was not found, which every caller treats as a failure rather than as "no
# mismatches" (docs/TESTING.md, "A guard answers three states, not two").
markdown_table() {
  local file="$1" heading="$2"
  awk -v want="$heading" '
    $0 == "#### " want { armed = 1; next }
    armed && /^#/      { exit }
    armed && /^\|/     { intable = 1; if ($0 ~ /^\|[ :|-]*\|[ :|-]*$/) next; print; next }
    armed && intable   { exit }
  ' "$file"
}

# The manual`s `fontsize' longtable body and header, one row per line, `&'
# preserved. Same three-state contract as markdown_table().
manual_table() {
  awk '
    /\\subsubsection[{]\\texttt[{]fontsize[}][}]/ { armed = 1; next }
    armed && /\\subsubsection/ { exit }
    armed && /\\begin[{]longtable[}]/ { intable = 1; next }
    armed && intable && /\\end[{]longtable[}]/ { exit }
    intable && /&/ { print }
  ' "$1"
}

# ---------------------------------------------------------------------------
# The four checks, each over one source and one document so the self-check can
# drive them against fixtures.
# ---------------------------------------------------------------------------

# Shared preamble: read the source, and refuse to compare against nothing.
# Sets `values' in the caller's scope.
load_source() {
  local file="$1" label="$2"
  values="$(source_values "$file")"
  if [ -z "$values" ]; then
    printf '  %-30s %s\n' "$label" "NO SOURCE VALUES"
    printf '    -> %s\n' "$(basename "$file") declares no calibrated value this lint can read; the shapes it parses have changed, so nothing was compared"
    return 1
  fi
  return 0
}

# 1 and 2. The vertical-rhythm table: ratios against the source, point columns
# against ratio x body baseline, and the two token sets against each other.
check_rhythm() {
  local src="$1" doc="$2" values table label
  label="$(basename "$doc")"

  load_source "$src" "$label" || return 1

  table="$(markdown_table "$doc" "Vertical rhythm")"
  if [ -z "$table" ]; then
    printf '  %-30s %s\n' "$label" "NO TABLE FOUND"
    printf '    -> %s\n' "no table under '#### Vertical rhythm' in $label; the heading or the table shape has changed, so no ratio was compared"
    return 1
  fi

  # The comparison itself. Fed the source stream and the table on one input, in
  # that order, separated by a marker line.
  { printf '%s\n' "$values"; echo "--TABLE--"; printf '%s\n' "$table"; } |
  awk -v tol="$tolerance" -v label="$label" '
    function trim(s) { gsub(/`/, "", s); sub(/^[[:space:]]+/, "", s); sub(/[[:space:]]+$/, "", s); return s }
    function abs(x)  { return x < 0 ? -x : x }

    $0 == "--TABLE--" { intable = 1; next }

    !intable && $1 == "ratio"   { ratio[$2] = $3; ratios++; next }
    !intable && $1 == "leading" { leading[$2] = $3; next }
    !intable && $1 == "bodysize" { bodysize[$2] = $3; next }
    !intable { next }

    # The header row names the fontsize each point column carries, so a column
    # reordered in the table cannot pass by position.
    !seen_header {
      seen_header = 1
      n = split($0, field, "|")
      for (i = 1; i <= n; i++) {
        f = trim(field[i])
        if (f ~ /^1[012]pt$/) { column[i] = f; columns++ }
      }
      next
    }

    {
      n = split($0, field, "|")
      token = trim(field[2]); sub(/^\\/, "", token)
      if (token == "") next
      rows++
      if (!(token in ratio)) {
        printf "  %-30s %-20s %s\n", label, "UNKNOWN TOKEN", "\\" token
        printf "    -> %s\n", "the table states a ratio for \\" token ", which careerdossier-tokens.sty does not declare with \\__cdossier_tokens_set_skip:Nn"
        bad = 1
        next
      }
      documented[token] = 1

      stated = trim(field[3]) + 0
      if (abs(stated - ratio[token]) > tol) {
        printf "  %-30s %-20s %s\n", label, "RATIO MISMATCH", "\\" token
        printf "    -> %s\n", "the table states " trim(field[3]) "; careerdossier-tokens.sty declares " ratio[token]
        bad = 1
      }

      for (i = 1; i <= n; i++) {
        if (!(i in column)) continue
        size = column[i]
        cell = trim(field[i]); sub(/[[:space:]]*pt$/, "", cell)
        if (cell == "") continue
        expected = ratio[token] * leading[size]
        if (abs(cell + 0 - expected) > tol) {
          printf "  %-30s %-20s %s\n", label, "VALUE MISMATCH", "\\" token " at " size
          printf "    -> %s\n", "the table states " cell " pt; " ratio[token] " x " leading[size] " pt is " sprintf("%.5f", expected) " pt"
          bad = 1
        }
        values_checked++
      }
    }

    END {
      if (columns != 3) {
        printf "  %-30s %-20s %s\n", label, "NO VALUE COLUMNS", columns " found"
        printf "    -> %s\n", "the header row names no three fontsize columns, so no resolved value was compared"
        exit 1
      }
      for (token in ratio) {
        if (!(token in documented)) {
          printf "  %-30s %-20s %s\n", label, "MISSING ROW", "\\" token
          printf "    -> %s\n", "careerdossier-tokens.sty declares this ratio and the table has no row for it"
          bad = 1
        }
      }
      if (bad) exit 1
      printf "  %-30s %s\n", label, rows " ratios and " values_checked " resolved values, all from the source"
      exit 0
    }
  '
}

# 3a. The type-scale table: size/leading pairs against the source.
check_type_scale() {
  local src="$1" doc="$2" values table label
  label="$(basename "$doc")"

  load_source "$src" "$label" || return 1

  table="$(markdown_table "$doc" "Type scale")"
  if [ -z "$table" ]; then
    printf '  %-30s %s\n' "$label" "NO TABLE FOUND"
    printf '    -> %s\n' "no table under '#### Type scale' in $label; the heading or the table shape has changed, so no size pair was compared"
    return 1
  fi

  { printf '%s\n' "$values"; echo "--TABLE--"; printf '%s\n' "$table"; } |
  awk -v tol="$tolerance" -v label="$label" '
    function trim(s) { gsub(/`/, "", s); sub(/^[[:space:]]+/, "", s); sub(/[[:space:]]+$/, "", s); return s }
    function abs(x)  { return x < 0 ? -x : x }

    $0 == "--TABLE--" { intable = 1; next }
    !intable && $1 == "scale" { size[$2 SUBSEP $3] = $4; lead[$2 SUBSEP $3] = $5; declared[$3] = 1; next }
    !intable { next }

    !seen_header {
      seen_header = 1
      n = split($0, field, "|")
      for (i = 1; i <= n; i++) { f = trim(field[i]); if (f ~ /^1[012]pt$/) { column[i] = f; columns++ } }
      next
    }

    {
      n = split($0, field, "|")
      selector = trim(field[3]); sub(/^\\/, "", selector)
      if (selector == "") next
      rows++
      if (!(selector in declared)) {
        printf "  %-30s %-20s %s\n", label, "UNKNOWN SELECTOR", "\\" selector
        printf "    -> %s\n", "the table states a size pair for \\" selector ", which careerdossier-tokens.sty does not declare"
        bad = 1
        next
      }
      documented[selector] = 1

      for (i = 1; i <= n; i++) {
        if (!(i in column)) continue
        fs = column[i]
        cell = trim(field[i])
        if (cell == "") continue
        if (split(cell, part, "/") != 2) {
          printf "  %-30s %-20s %s\n", label, "UNREADABLE PAIR", "\\" selector " at " fs
          printf "    -> %s\n", "the cell reads '" cell "'; this table states size / leading"
          bad = 1
          continue
        }
        want_size = size[fs SUBSEP selector]; want_lead = lead[fs SUBSEP selector]
        if (abs(trim(part[1]) + 0 - want_size) > tol || abs(trim(part[2]) + 0 - want_lead) > tol) {
          printf "  %-30s %-20s %s\n", label, "SCALE MISMATCH", "\\" selector " at " fs
          printf "    -> %s\n", "the table states " cell "; careerdossier-tokens.sty declares " want_size " / " want_lead
          bad = 1
        }
        pairs++
      }
    }

    END {
      if (columns != 3) {
        printf "  %-30s %-20s %s\n", label, "NO VALUE COLUMNS", columns " found"
        printf "    -> %s\n", "the header row names no three fontsize columns, so no size pair was compared"
        exit 1
      }
      for (selector in declared) {
        if (!(selector in documented)) {
          printf "  %-30s %-20s %s\n", label, "MISSING ROW", "\\" selector
          printf "    -> %s\n", "careerdossier-tokens.sty declares this selector and the table has no row for it"
          bad = 1
        }
      }
      if (bad) exit 1
      printf "  %-30s %s\n", label, rows " type-scale rows and " pairs " size pairs, all from the source"
      exit 0
    }
  '
}

# 3b. The derived-metrics table. Three rows are a factor times the body size;
# \CDossierFurnitureLeading is not derived at all but set per fontsize, and its
# derivation column says so, so it is compared against that declaration and
# against the type scale it claims to follow.
check_derived() {
  local src="$1" doc="$2" values table label
  label="$(basename "$doc")"

  load_source "$src" "$label" || return 1

  table="$(markdown_table "$doc" "Derived metrics")"
  if [ -z "$table" ]; then
    printf '  %-30s %s\n' "$label" "NO TABLE FOUND"
    printf '    -> %s\n' "no table under '#### Derived metrics' in $label; the heading or the table shape has changed, so no derivation was compared"
    return 1
  fi

  { printf '%s\n' "$values"; echo "--TABLE--"; printf '%s\n' "$table"; } |
  awk -v tol="$tolerance" -v label="$label" '
    function trim(s) { gsub(/`/, "", s); sub(/^[[:space:]]+/, "", s); sub(/[[:space:]]+$/, "", s); return s }
    function abs(x)  { return x < 0 ? -x : x }

    $0 == "--TABLE--" { intable = 1; next }
    !intable && $1 == "derived"   { factor[$2] = $3; basis[$2] = $4; declared[$2] = 1; next }
    !intable && $1 == "bodysize"  { bodysize[$2] = $3; next }
    !intable && $1 == "furniture" { furniture[$2] = $3; declared["CDossierFurnitureLeading"] = 1; next }
    !intable && $1 == "scale" && $3 == "CDossierSizeFurniture" { furniture_lead[$2] = $5; next }
    !intable { next }

    !seen_header {
      seen_header = 1
      n = split($0, field, "|")
      for (i = 1; i <= n; i++) { f = trim(field[i]); if (f ~ /^1[012]pt$/) { column[i] = f; columns++ } }
      next
    }

    {
      n = split($0, field, "|")
      token = trim(field[2]); sub(/^\\/, "", token)
      if (token == "") next
      rows++
      if (!(token in declared)) {
        printf "  %-30s %-20s %s\n", label, "UNKNOWN TOKEN", "\\" token
        printf "    -> %s\n", "the table states a derivation for \\" token ", which careerdossier-tokens.sty does not declare in a shape this lint reads"
        bad = 1
        next
      }
      documented[token] = 1

      derivation = trim(field[3])

      if (token != "CDossierFurnitureLeading") {
        stated = derivation; sub(/[^0-9.].*/, "", stated)
        if (abs(stated + 0 - factor[token]) > tol) {
          printf "  %-30s %-20s %s\n", label, "FACTOR MISMATCH", "\\" token
          printf "    -> %s\n", "the table states '" derivation "'; careerdossier-tokens.sty declares " factor[token] " x \\" basis[token]
          bad = 1
        }
      }

      for (i = 1; i <= n; i++) {
        if (!(i in column)) continue
        fs = column[i]
        cell = trim(field[i]); sub(/[[:space:]]*pt$/, "", cell)
        if (cell == "") continue
        if (token == "CDossierFurnitureLeading") {
          expected = furniture[fs]
          # The derivation column claims this is the leading of
          # \CDossierSizeFurniture. If the two ever part, the claim is stale
          # even where the number still matches the declaration.
          if (abs(furniture[fs] - furniture_lead[fs]) > tol) {
            printf "  %-30s %-20s %s\n", label, "DERIVATION STALE", "\\" token " at " fs
            printf "    -> %s\n", "the table calls this the leading of \\CDossierSizeFurniture (" furniture_lead[fs] " pt), but the token is set to " furniture[fs] " pt"
            bad = 1
          }
        } else {
          expected = factor[token] * bodysize[fs]
        }
        if (abs(cell + 0 - expected) > tol) {
          printf "  %-30s %-20s %s\n", label, "VALUE MISMATCH", "\\" token " at " fs
          printf "    -> %s\n", "the table states " cell " pt; the source gives " sprintf("%.5f", expected) " pt"
          bad = 1
        }
        values_checked++
      }
    }

    END {
      if (columns != 3) {
        printf "  %-30s %-20s %s\n", label, "NO VALUE COLUMNS", columns " found"
        printf "    -> %s\n", "the header row names no three fontsize columns, so no derived value was compared"
        exit 1
      }
      for (token in declared) {
        if (!(token in documented)) {
          printf "  %-30s %-20s %s\n", label, "MISSING ROW", "\\" token
          printf "    -> %s\n", "careerdossier-tokens.sty declares this metric and the table has no row for it"
          bad = 1
        }
      }
      if (bad) exit 1
      printf "  %-30s %s\n", label, rows " derived rows and " values_checked " resolved values, all from the source"
      exit 0
    }
  '
}

# 4. The manual's `fontsize' table, against the same source.
check_manual_sizes() {
  local src="$1" doc="$2" values table label
  label="$(basename "$doc")"

  load_source "$src" "$label" || return 1

  table="$(manual_table "$doc")"
  if [ -z "$table" ]; then
    printf '  %-30s %s\n' "$label" "NO TABLE FOUND"
    printf '    -> %s\n' "no longtable under the 'fontsize' subsubsection in $label; the heading or the table shape has changed, so no size was compared"
    return 1
  fi

  { printf '%s\n' "$values"; echo "--ROLES--"; printf '%s\n' "$manual_roles"
    echo "--TABLE--"; printf '%s\n' "$table"; } |
  awk -v tol="$tolerance" -v label="$label" '
    function trim(s) {
      gsub(/\\opt[{]/, "", s); gsub(/\\textbf[{]/, "", s)
      gsub(/[{}]/, "", s)
      sub(/[[:space:]]*\\\\[[:space:]]*$/, "", s)
      sub(/^[[:space:]]+/, "", s); sub(/[[:space:]]+$/, "", s)
      return s
    }
    function abs(x) { return x < 0 ? -x : x }

    $0 == "--ROLES--" { inroles = 1; next }
    $0 == "--TABLE--" { inroles = 0; intable = 1; next }

    !inroles && !intable && $1 == "scale" { size[$2 SUBSEP $3] = $4; declared[$3] = 1; next }
    !inroles && !intable { next }

    inroles {
      i = index($0, "=")
      if (i > 0) { role[substr($0, 1, i - 1)] = substr($0, i + 1); mapped++ }
      next
    }

    !seen_header {
      seen_header = 1
      n = split($0, field, "&")
      for (i = 1; i <= n; i++) { f = trim(field[i]); if (f ~ /^1[012]pt$/) { column[i] = f; columns++ } }
      next
    }

    {
      n = split($0, field, "&")
      label_text = trim(field[1])
      if (label_text == "") next
      rows++
      if (!(label_text in role)) {
        printf "  %-30s %-20s %s\n", label, "UNKNOWN ROLE", label_text
        printf "    -> %s\n", "this table names roles, not tokens, so the lint carries an explicit role-to-token map; a row it cannot map is skipped silently unless it fails here. Add '"'"'" label_text "'"'"' to manual_roles in tests/lint/run-token-values.sh, naming the selector it documents"
        bad = 1
        next
      }
      selector = role[label_text]
      if (!(selector in declared)) {
        printf "  %-30s %-20s %s\n", label, "UNKNOWN SELECTOR", "\\" selector
        printf "    -> %s\n", "the role map sends '"'"'" label_text "'"'"' to \\" selector ", which careerdossier-tokens.sty does not declare"
        bad = 1
        next
      }
      documented[selector] = 1

      for (i = 1; i <= n; i++) {
        if (!(i in column)) continue
        fs = column[i]
        cell = trim(field[i])
        if (cell == "") continue
        want = size[fs SUBSEP selector]
        if (abs(cell + 0 - want) > tol) {
          printf "  %-30s %-20s %s\n", label, "MANUAL VALUE MISMATCH", "\\" selector " at " fs
          printf "    -> %s\n", "the table states " cell "; careerdossier-tokens.sty declares " want
          bad = 1
        }
        values_checked++
      }
    }

    END {
      if (mapped == 0) {
        printf "  %-30s %s\n", label, "NO ROLE MAP"
        exit 1
      }
      if (columns != 3) {
        printf "  %-30s %-20s %s\n", label, "NO VALUE COLUMNS", columns " found"
        printf "    -> %s\n", "the header row names no three fontsize columns, so no size was compared"
        exit 1
      }
      for (selector in declared) {
        if (!(selector in documented)) {
          printf "  %-30s %-20s %s\n", label, "MISSING ROW", "\\" selector
          printf "    -> %s\n", "careerdossier-tokens.sty declares this selector and the manual table has no row for it"
          bad = 1
        }
      }
      if (bad) exit 1
      printf "  %-30s %s\n", label, rows " roles and " values_checked " sizes, all from the source"
      exit 0
    }
  '
}

# ---------------------------------------------------------------------------
# The run.
# ---------------------------------------------------------------------------

fail=0

echo "== docs/ARCHITECTURE.md against careerdossier-tokens.sty =="
if [ ! -f "$source_file" ]; then
  printf '  %-30s %s\n' "careerdossier-tokens.sty" "MISSING"
  fail=1
elif [ ! -f "$architecture" ]; then
  printf '  %-30s %s\n' "docs/ARCHITECTURE.md" "MISSING"
  fail=1
else
  check_rhythm     "$source_file" "$architecture" || fail=1
  check_type_scale "$source_file" "$architecture" || fail=1
  check_derived    "$source_file" "$architecture" || fail=1
fi

echo
echo "== the manual's fontsize table =="
if [ ! -f "$manual" ]; then
  printf '  %-30s %s\n' "doc/careerdossier.tex" "MISSING"
  printf '    -> %s\n' "the manual CTAN requires is absent; see issue #263"
  fail=1
else
  check_manual_sizes "$source_file" "$manual" || fail=1
fi

# Self-check. One fixture per verdict, so a checker that stopped detecting a
# defect -- or started rejecting a correct document -- fails here.
echo
echo "== fixtures (the lint's own failure modes) =="
self_check() {
  local doc="$1" fn="$2" expected="$3" src="${4:-tokenfixture-source.sty}" out rc
  case "$fn" in
    rhythm)   out="$(check_rhythm       "$fixtures/$src" "$fixtures/$doc")" ;;
    scale)    out="$(check_type_scale   "$fixtures/$src" "$fixtures/$doc")" ;;
    derived)  out="$(check_derived      "$fixtures/$src" "$fixtures/$doc")" ;;
    manual)   out="$(check_manual_sizes "$fixtures/$src" "$fixtures/$doc")" ;;
  esac
  rc=$?
  if [ "$expected" = "OK" ]; then
    if [ "$rc" -ne 0 ]; then
      echo "  $doc ($fn) EXPECTED PASS but the lint reported:"
      printf '%s\n' "$out" | sed 's/^/    /'
      fail=1
    else
      echo "  $doc ($fn) accepted as intended"
    fi
    return
  fi
  if [ "$rc" -eq 0 ]; then
    echo "  $doc ($fn) EXPECTED FAILURE but the lint passed it"
    fail=1
    return
  fi
  # Issue #398: three states. A check that could not run is not a report about
  # the lint's message.
  case "$out" in
    '')
      echo "  $doc ($fn) PRODUCED NO CHECKABLE OUTPUT: '$expected' was never"
      echo "    looked for, so the rejection has not been shown to be intended."
      fail=1
      ;;
    *"$expected"*) echo "  $doc ($fn) rejected as intended ($expected)" ;;
    *)
      echo "  $doc ($fn) FAILED for the wrong reason: expected '$expected', got:"
      printf '%s\n' "$out" | sed 's/^/    /'
      fail=1
      ;;
  esac
}

self_check tokenfixture-arch-ok.md       rhythm  "OK"
self_check tokenfixture-arch-ok.md       scale   "OK"
self_check tokenfixture-arch-ok.md       derived "OK"
self_check tokenfixture-arch-ratio.md    rhythm  "RATIO MISMATCH"
self_check tokenfixture-arch-value.md    rhythm  "VALUE MISMATCH"
self_check tokenfixture-arch-dropped.md  rhythm  "MISSING ROW"
self_check tokenfixture-arch-extra.md    rhythm  "UNKNOWN TOKEN"
self_check tokenfixture-arch-scale.md    scale   "SCALE MISMATCH"
self_check tokenfixture-arch-derived.md  derived "FACTOR MISMATCH"
self_check tokenfixture-arch-notable.md  rhythm  "NO TABLE FOUND"
self_check tokenfixture-arch-notable.md  scale   "NO TABLE FOUND"
self_check tokenfixture-arch-notable.md  derived "NO TABLE FOUND"
self_check tokenfixture-arch-ok.md       rhythm  "NO SOURCE VALUES" tokenfixture-nosource.sty

self_check tokenfixture-manual-ok.tex      manual "OK"
self_check tokenfixture-manual-value.tex   manual "MANUAL VALUE MISMATCH"
self_check tokenfixture-manual-unknown.tex manual "UNKNOWN ROLE"
self_check tokenfixture-manual-notable.tex manual "NO TABLE FOUND"

echo
if [ "$fail" -ne 0 ]; then
  echo "token-value lint: FAIL"
  exit 1
fi
echo "token-value lint: OK"
