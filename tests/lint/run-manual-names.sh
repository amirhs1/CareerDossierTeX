#!/usr/bin/env bash
# run-manual-names.sh — the PDF manual's names and version (issue #263)
#
# The manual (doc/careerdossier.tex) became the authored reference for the
# public interface when docs/API.md was reduced to a pointer. Two of that
# issue's acceptance criteria are assertions about it rather than prose:
#
#   "Every public name documented in the manual exists in the source; no
#    private name appears."
#
# Neither is checkable by compiling the manual: a manual documenting
# \CDossierSubsectoin -- or still documenting a command deleted two releases
# ago -- typesets perfectly and reads as authoritative. LaTeX never sees these
# names as names; they are words in a document.
#
# So this lint reads the manual as text and asserts three things:
#
#   1. No private LaTeX3 name (`\__cdossier_...') appears. AGENTS.md "Code and
#      API conventions" requires private names to stay out of public
#      documentation; CONTRIBUTING.md "Coding conventions" is canonical.
#   2. Every public name the manual mentions -- `\CDossier...',
#      `\MakeCDossier...', and the `CDossier...' environments -- appears in a
#      file the manifest lists under "The Work". A name that appears nowhere in
#      the Work is a typo or a command that has been removed.
#   3. The version and date the manual declares match the ones the Work
#      declares, and so does README.md's "current release" block.
#
# (3) is the folded-in half of a separate finding. Before this file,
# run-version-declarations.sh checked the .sty/.cls declarations against
# manifest.txt and nothing checked the *documentation*, which named the release
# in two further places. The manual would have made that a third. Only these
# two are checked, and deliberately: they are declarations, in a fixed shape,
# of what release this is. docs/MIGRATION.md's prose mentions many versions and
# is narrative rather than a declaration, so a grep for a version string there
# would match history and fail on nothing useful.
#
# Check (2) is deliberately weak: it asks whether the name occurs in the Work
# at all, not whether it occurs in a definition. A stricter form would have to
# know every way expl3, xparse, and the kernel can bind a name, and would fail
# on the ones it did not know -- reporting the lint's gaps as the manual's. The
# weak form still catches both failures that actually happen: a name misspelled
# in the manual, and a name removed from the source while the manual keeps it.
#
# The lint parses text; it runs no LaTeX and needs no TeX installation.
# Requirements: bash and awk. Run from anywhere. It ends by running itself
# against tests/lint/fixtures/manual-*.tex, one per verdict, so a lint that had
# stopped detecting anything fails here rather than passing everything.
#
# Portability, as in the sibling lints: local `grep' is ugrep and CI's is GNU
# grep, local `awk' is one-true-awk and CI's is gawk or mawk. A brace is written
# `[{]' rather than `\{'. Run under bash, not zsh: zsh does not word-split
# unquoted parameter expansions, so a name list developed there collapses into
# one string.
set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../.." && pwd)"

# Output guards that answer "could not check" apart from "absent" (issue #398).
# shellcheck source=tests/lib/text.sh
. "$root/tests/lib/text.sh"

fixtures="$here/fixtures"

manual="$root/doc/careerdossier.tex"
backlog="$here/manual-undocumented.txt"
readme="$root/README.md"

# ---------------------------------------------------------------------------
# The Work, and the names it declares.
# ---------------------------------------------------------------------------

# The .sty/.cls filenames the manifest lists under "The Work". Same section
# parse as run-version-declarations.sh, which owns the consistency check over
# these files; here the list is only used to bound where a name may live.
work_files() {
  awk '
    /^The Work$/            { inwork = 1; next }
    /^Distributed with the/ { inwork = 0 }
    /^Not distributed$/     { inwork = 0 }
    inwork && $1 ~ /\.(sty|cls)$/ { print $1 }
  ' "$root/manifest.txt"
}

# Every public name the Work mentions anywhere, one per line. Definitions are
# not distinguished from uses; see the header for why.
work_names() {
  local file
  for file in $(work_files); do
    [ -f "$root/$file" ] || continue
    cat "$root/$file"
  done | awk '
    {
      line = $0
      while (match(line, /\\?(Make)?CDossier[A-Za-z]+/)) {
        name = substr(line, RSTART, RLENGTH)
        sub(/^\\/, "", name)
        print name
        line = substr(line, RSTART + RLENGTH)
      }
    }
  ' | sort -u
}

# Every public name the manual mentions, one per line, with the manual's own
# locally defined macros removed -- \CDossierManualVersion and
# \CDossierManualDate are the manual's, not the toolkit's, and asking the Work
# to declare them would be wrong.
manual_names() {
  local file="$1"
  awk '
    # Names the file defines itself are not claims about the Work.
    /\\newcommand[{]\\[A-Za-z]+[}]/ {
      line = $0
      while (match(line, /\\newcommand[{]\\[A-Za-z]+[}]/)) {
        defn = substr(line, RSTART, RLENGTH)
        sub(/^\\newcommand[{]\\/, "", defn)
        sub(/[}]$/, "", defn)
        local[defn] = 1
        line = substr(line, RSTART + RLENGTH)
      }
    }
    {
      line = $0
      while (match(line, /\\?(Make)?CDossier[A-Za-z]+/)) {
        name = substr(line, RSTART, RLENGTH)
        sub(/^\\/, "", name)
        seen[name] = 1
        line = substr(line, RSTART + RLENGTH)
      }
    }
    END {
      for (name in seen)
        if (!(name in local))
          print name
    }
  ' "$file" | sort -u
}

# Every public name the Work *defines*, one per line, with TeX comments removed
# first. Check (4) needs a different set from work_names() above, and that
# difference is the whole subtlety of it.
#
# work_names() deliberately counts a name mentioned in a comment, because for
# check (2) that is still a claim worth validating. Here the same inclusion
# would be a false positive with teeth. Three names appear in this tree *only*
# inside comments recording that issue #242 made them private --
# \CDossierApplyBodySize, \CDossierApplyGeometry, and
# \MakeCDossierPageFurniture. They are private now. Asking the manual to
# document them would pressure an author into documenting a private name, which
# is exactly what check (1) exists to reject.
#
# A TeX comment runs from the first unescaped `%' to end of line, so `\%' is a
# literal percent and starts none. Stripping on a bare /%/ would truncate any
# line containing one and lose every name after it.
work_defined_names() {
  local file
  for file in $(work_files); do
    [ -f "$root/$file" ] || continue
    cat "$root/$file"
  done | awk '
    {
      line = $0
      out = ""
      while (length(line) > 0) {
        i = index(line, "%")
        if (i == 0) { out = out line; break }
        slashes = 0
        j = i - 1
        while (j >= 1 && substr(line, j, 1) == "\\") { slashes++; j-- }
        if (slashes % 2 == 1) {
          out = out substr(line, 1, i)
          line = substr(line, i + 1)
          continue
        }
        out = out substr(line, 1, i - 1)
        break
      }
      print out
    }
  ' | awk '
    {
      line = $0
      while (match(line, /\\?(Make)?CDossier[A-Za-z]+/)) {
        name = substr(line, RSTART, RLENGTH)
        sub(/^\\/, "", name)
        print name
        line = substr(line, RSTART + RLENGTH)
      }
    }
  ' | sort -u
}

# The ratchet list: names accepted as undocumented, each with its reason.
# Prints `name<TAB>reason'. An entry with no reason prints an empty second
# field rather than being dropped, so the caller can reject it -- silently
# skipping it is how the mandatory reason would stop being mandatory.
backlog_entries() {
  local file="$1"
  [ -f "$file" ] || return 0
  awk '
    /^[[:space:]]*#/ { next }
    /^[[:space:]]*$/ { next }
    {
      name = $1
      reason = $0
      sub(/^[[:space:]]*[^[:space:]]+/, "", reason)
      sub(/^[[:space:]]+/, "", reason)
      printf "%s\t%s\n", name, reason
    }
  ' "$file"
}

# ---------------------------------------------------------------------------
# The four checks, each over one file so the self-check can drive them.
# ---------------------------------------------------------------------------

# 1. No private LaTeX3 name.
check_private_names() {
  local file="$1" hits
  hits="$(grep -n '\\__cdossier_' "$file" 2>/dev/null)"
  if [ -n "$hits" ]; then
    printf '  %-32s %s\n' "$(basename "$file")" "PRIVATE NAME"
    printf '%s\n' "$hits" | sed 's/^/    -> /'
    printf '    -> %s\n' "a private LaTeX3 name is not public interface; document the public command instead"
    return 1
  fi
  printf '  %-32s %s\n' "$(basename "$file")" "no private names"
  return 0
}

# 2. Every public name exists in the Work.
check_public_names() {
  local file="$1" declared names name bad=0 checked=0
  declared="$(work_names)"

  if [ -z "$declared" ]; then
    printf '  %-32s %s\n' "$(basename "$file")" "NO WORK NAMES FOUND"
    printf '    -> %s\n' "the Work declares no CDossier name, so this check cannot have run; manifest.txt or the sources are unreadable"
    return 1
  fi

  names="$(manual_names "$file")"
  if [ -z "$names" ]; then
    printf '  %-32s %s\n' "$(basename "$file")" "NO NAMES FOUND"
    printf '    -> %s\n' "the manual mentions no public name at all, which no real manual does; the extraction has stopped matching"
    return 1
  fi

  local nl='
'
  for name in $names; do
    checked=$((checked + 1))
    case "$nl$declared$nl" in
      *"$nl$name$nl"*) continue ;;
    esac
    if [ "$bad" -eq 0 ]; then
      printf '  %-32s %s\n' "$(basename "$file")" "UNKNOWN NAME"
    fi
    printf '    -> %s\n' "\\$name is documented but appears in no file of the Work"
    bad=1
  done

  [ "$bad" -eq 0 ] && printf '  %-32s %s\n' "$(basename "$file")" "$checked public names, all in the Work"
  return "$bad"
}

# 3. The declared release, in the manual and in README.md, against the Work's.
#
# The reference is the Work's own declaration. run-version-declarations.sh owns
# the assertion that the Work agrees with itself, so a disagreement here defers
# to it rather than reporting a second, differently worded failure.
work_release() {
  local file decl
  for file in $(work_files); do
    [ -f "$root/$file" ] || continue
    decl="$(awk '
      /\\ProvidesExpl(Package|Class)/ {
        if (match($0, /[{][ ]*[0-9]{4}-[0-9]{2}-[0-9]{2}[ ]*[}][ ]*[{][ ]*[0-9]+\.[0-9]+\.[0-9]+[ ]*[}]/)) {
          field = substr($0, RSTART, RLENGTH)
          gsub(/[{}  ]/, " ", field)
          split(field, part, " ")
          for (i = 1; i <= 4; i++)
            if (part[i] != "") { out = out part[i] " " }
          print out
          exit
        }
      }
    ' "$root/$file")"
    if [ -n "$decl" ]; then
      printf '%s' "$decl" | awk '{ print $2 " " $1 }'
      return 0
    fi
  done
  return 1
}

check_declared_release() {
  local file="$1" kind="$2" reference version date bad=0
  reference="$(work_release)"
  if [ -z "$reference" ]; then
    printf '  %-32s %s\n' "$(basename "$file")" "NO WORK RELEASE FOUND"
    printf '    -> %s\n' "no Work file carries a parseable \\ProvidesExpl* declaration; run-version-declarations.sh owns that failure"
    return 1
  fi
  set -- $reference
  local ref_version="$1" ref_date="$2"

  case "$kind" in
    manual)
      version="$(awk 'match($0, /\\newcommand[{]\\CDossierManualVersion[}][{][^}]*[}]/) {
                        field = substr($0, RSTART, RLENGTH)
                        sub(/.*[}][{]/, "", field); sub(/[}]$/, "", field)
                        print field; exit }' "$file")"
      date="$(awk 'match($0, /\\newcommand[{]\\CDossierManualDate[}][{][^}]*[}]/) {
                     field = substr($0, RSTART, RLENGTH)
                     sub(/.*[}][{]/, "", field); sub(/[}]$/, "", field)
                     print field; exit }' "$file")"
      ;;
    readme)
      # The fenced block under "The current release is:", whose first line is
      # `v<x>.<y>.<z> — <name>'. The version is all this lint reads; the release
      # name is prose.
      version="$(awk '
        /^The current release is:/ { armed = 1; next }
        armed && /^```/            { infence = !infence; if (!infence) exit; next }
        armed && infence && match($0, /^v[0-9]+\.[0-9]+\.[0-9]+/) {
          print substr($0, 2, RLENGTH - 1); exit
        }' "$file")"
      date=""
      ;;
  esac

  if [ -z "$version" ]; then
    printf '  %-32s %s\n' "$(basename "$file")" "NO DECLARED RELEASE"
    printf '    -> %s\n' "no release declaration was found in $(basename "$file"); the shape this lint reads has changed, so nothing was compared"
    return 1
  fi

  if [ "$version" != "$ref_version" ]; then
    printf '  %-32s %-24s %s\n' "$(basename "$file")" "VERSION MISMATCH" "$version"
    printf '    -> %s\n' "$(basename "$file") declares $version; the Work declares $ref_version"
    bad=1
  fi

  if [ -n "$date" ] && [ "$date" != "$ref_date" ]; then
    printf '  %-32s %-24s %s\n' "$(basename "$file")" "DATE MISMATCH" "$date"
    printf '    -> %s\n' "$(basename "$file") declares $date; the Work declares $ref_date"
    bad=1
  fi

  [ "$bad" -eq 0 ] && printf '  %-32s %-24s %s\n' "$(basename "$file")" "release matches the Work" "$version"
  return "$bad"
}


# 4. Every public name the Work defines is documented in the manual.
#
# The mirror of check (2), and the direction that was missing: (2) stops the
# manual naming something that does not exist, (4) stops the Work exposing
# something the manual never mentions. A new public command could ship
# undocumented and every suite passed (issue #468).
#
# It ships as a ratchet rather than a policy. 52 of the 84 names the Work
# defines were undocumented when this was written, and a lint that fails on all
# of them on day one is a lint that gets commented out. So the accepted set is
# declared in tests/lint/manual-undocumented.txt, may only shrink, and #243 is
# what shrinks it. What this catches from day one is the 53rd.
#
# Three ways to fail, and the second and third are what keep the list honest:
# a name neither documented nor listed; a listed name with no reason, per
# control 8 of run-text-guards.sh -- an exemption must cost an argument, or the
# ratchet becomes a formality; and a listed name the Work no longer defines, so
# the list cannot rot behind the source.
check_documented_names() {
  local file="$1" backlog="$2" defined_from="${3:-}"
  local defined documented entries name reason bad=0 listed=0 remaining=0
  local nl='
'

  # The self-check drives this against fixture files, and a fixture manual
  # cannot document all 84 names the real Work defines. So the defined set is
  # an optional third argument -- one name per line -- and defaults to the Work
  # itself, which is what every real run uses.
  if [ -n "$defined_from" ]; then
    defined="$(sed -e 's/[[:space:]]*#.*$//' -e '/^[[:space:]]*$/d' "$defined_from" | sort -u)"
  else
    defined="$(work_defined_names)"
  fi
  if [ -z "$defined" ]; then
    printf '  %-32s %s\n' "$(basename "$file")" "NO WORK NAMES FOUND"
    printf '    -> %s\n' "the Work defines no CDossier name outside comments, so this check cannot have run; manifest.txt or the sources are unreadable"
    return 1
  fi

  documented="$(manual_names "$file")"
  if [ -z "$documented" ]; then
    printf '  %-32s %s\n' "$(basename "$file")" "NO NAMES FOUND"
    printf '    -> %s\n' "the manual mentions no public name at all, which no real manual does; the extraction has stopped matching"
    return 1
  fi

  entries="$(backlog_entries "$backlog")"

  # (a) A backlog entry must carry a reason, and must still name something the
  #     Work defines.
  while IFS="$(printf '\t')" read -r name reason; do
    [ -n "$name" ] || continue
    listed=$((listed + 1))
    if [ -z "$reason" ]; then
      printf '  %-32s %-24s %s\n' "$(basename "$backlog")" "NO REASON" "$name"
      printf '    -> %s\n' "every backlog entry states why the name is not yet documented; an exemption must cost an argument, not a keyword (run-text-guards.sh control 8)"
      bad=1
      continue
    fi
    case "$nl$defined$nl" in
      *"$nl$name$nl"*) ;;
      *)
        printf '  %-32s %-24s %s\n' "$(basename "$backlog")" "STALE ENTRY" "$name"
        printf '    -> %s\n' "the Work no longer defines this name; delete the line rather than leave the list describing a tree that has moved on"
        bad=1
        ;;
    esac
  done <<EOF
$entries
EOF

  # (b) Every defined name is documented, or listed.
  for name in $defined; do
    case "$nl$documented$nl" in
      *"$nl$name$nl"*) continue ;;
    esac
    case "$nl$(printf '%s\n' "$entries" | cut -f1)$nl" in
      *"$nl$name$nl"*) remaining=$((remaining + 1)); continue ;;
    esac
    if [ "$bad" -eq 0 ]; then
      printf '  %-32s %s\n' "$(basename "$file")" "UNDOCUMENTED NAME"
    fi
    printf '    -> %s\n' "\\$name is defined in the Work but appears nowhere in $(basename "$file")"
    bad=1
  done

  if [ "$bad" -ne 0 ]; then
    printf '    %s\n' "Document the name in doc/careerdossier.tex, or -- if it should"
    printf '    %s\n' "not be public -- rename it to \\__cdossier_<module>_<action>:<sig>."
    printf '    %s\n' "Adding it to $(basename "$backlog") is for names #243 has yet to"
    printf '    %s\n' "classify, not for new ones. See issue #468."
    return 1
  fi

  if [ "$remaining" -eq 0 ]; then
    printf '  %-32s %s\n' "$(basename "$file")" "every public name documented"
    printf '    -> %s\n' "the backlog is empty: delete $(basename "$backlog") and this check's backlog branch (#468)"
  else
    printf '  %-32s %-24s %s\n' "$(basename "$file")" "documented, $remaining on backlog" "of $listed listed"
  fi
  return 0
}

# ---------------------------------------------------------------------------
# The run.
# ---------------------------------------------------------------------------

fail=0

echo "== the manual's names =="
if [ ! -f "$manual" ]; then
  printf '  %-32s %s\n' "doc/careerdossier.tex" "MISSING"
  printf '    -> %s\n' "the manual CTAN requires is absent; see issue #263"
  fail=1
else
  check_private_names "$manual" || fail=1
  check_public_names  "$manual" || fail=1
  check_documented_names "$manual" "$backlog" || fail=1
fi

echo
echo "== the declared release =="
if [ -f "$manual" ]; then
  check_declared_release "$manual" manual || fail=1
fi
check_declared_release "$readme" readme || fail=1

# Self-check. One fixture per verdict, so a checker that stopped detecting a
# defect — or started rejecting a correct manual — fails here.
echo
echo "== fixtures (the lint's own failure modes) =="
self_check() {
  local fixture="$1" fn="$2" expected="$3" out rc
  case "$fn" in
    private) out="$(check_private_names "$fixtures/$fixture")" ;;
    public)  out="$(check_public_names  "$fixtures/$fixture")" ;;
    release) out="$(check_declared_release "$fixtures/$fixture" manual)" ;;
    documented) out="$(check_documented_names "$fixtures/$fixture" "$fixtures/$4" "$fixtures/manual-defined-names.txt")" ;;
  esac
  rc=$?
  if [ "$expected" = "OK" ]; then
    if [ "$rc" -ne 0 ]; then
      echo "  $fixture EXPECTED PASS but the lint reported:"
      printf '%s\n' "$out" | sed 's/^/    /'
      fail=1
    else
      echo "  $fixture accepted as intended"
    fi
    return
  fi
  if [ "$rc" -eq 0 ]; then
    echo "  $fixture EXPECTED FAILURE but the lint passed it"
    fail=1
    return
  fi
  # Issue #398: three states. A check that could not run is not a report about
  # the lint's message.
  case "$out" in
    '')
      echo "  $fixture PRODUCED NO CHECKABLE OUTPUT: '$expected' was never looked"
      echo "    for, so the rejection has not been shown to be the intended one."
      fail=1
      ;;
    *"$expected"*) echo "  $fixture rejected as intended ($expected)" ;;
    *)
      echo "  $fixture FAILED for the wrong reason: expected '$expected', got:"
      printf '%s\n' "$out" | sed 's/^/    /'
      fail=1
      ;;
  esac
}

self_check manualfixture-ok.tex       private "OK"
self_check manualfixture-ok.tex       public  "OK"
self_check manualfixture-ok.tex       release "OK"
self_check manualfixture-private.tex  private "PRIVATE NAME"
self_check manualfixture-unknown.tex  public  "UNKNOWN NAME"
self_check manualfixture-version.tex  release "VERSION MISMATCH"
self_check manualfixture-nonames.tex  public  "NO NAMES FOUND"

# Check (4). Each drives one verdict, and the backlog file is a parameter so a
# fixture can carry a deliberately broken list without touching the real one.
self_check manualfixture-documented.tex documented "OK"                 backlog-ok.txt
self_check manualfixture-documented.tex documented "UNDOCUMENTED NAME"  backlog-empty.txt
self_check manualfixture-documented.tex documented "NO REASON"          backlog-noreason.txt
self_check manualfixture-documented.tex documented "STALE ENTRY"        backlog-stale.txt

echo
if [ "$fail" -ne 0 ]; then
  echo "manual-name lint: FAIL"
  exit 1
fi
echo "manual-name lint: OK"
