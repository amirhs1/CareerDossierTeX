#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   bash scripts/setup-labels.sh
#
# Run from the root of the GitHub repository.
# Requires:
#   gh auth login

upsert_label() {
  local name="$1"
  local description="$2"
  local color="$3"

  if gh label list --limit 500 --json name --jq '.[].name' | grep -Fxq "$name"; then
    echo "Updating label: $name"
    gh label edit "$name" \
      --description "$description" \
      --color "$color"
  else
    echo "Creating label: $name"
    gh label create "$name" \
      --description "$description" \
      --color "$color"
  fi
}

# ------------------------------------------------------------
# Type labels
# ------------------------------------------------------------

upsert_label "type:feature" "New feature or user-facing improvement" "a2eeef"
upsert_label "type:bug" "Something is broken or not working as expected" "d73a4a"
upsert_label "type:docs" "Improvements or additions to documentation" "0075ca"
upsert_label "type:test" "Tests, examples, smoke checks, or regression coverage" "c5def5"
upsert_label "type:ci" "GitHub Actions, build automation, or status checks" "5319e7"
upsert_label "type:refactor" "Code restructuring without intended behavior change" "bfdadc"
upsert_label "type:release" "Release preparation, tagging, or release notes" "fbca04"

# ------------------------------------------------------------
# Area labels
# ------------------------------------------------------------

upsert_label "area:core" "Shared metadata, setup keys, validation, or base package logic" "1d76db"
upsert_label "area:resume" "Résumé class, résumé layout, or résumé examples" "0e8a16"
upsert_label "area:letter" "Cover-letter class, letter layout, or letter examples" "0e8a16"
upsert_label "area:cv" "Academic CV class, CV layout, or CV examples" "0e8a16"
upsert_label "area:bibliography" "BibLaTeX, Biber, publications, or citation support" "7057ff"
upsert_label "area:i18n" "Language abstraction, translations, Farsi, bilingual, or RTL support" "7057ff"
upsert_label "area:typography" "Fonts, text styles, spacing, or typographic hierarchy" "d4c5f9"
upsert_label "area:theme" "Colors, rules, visual tokens, or theme options" "d4c5f9"
upsert_label "area:components" "Shared document parts such as headers, contact lines, and entries" "d4c5f9"
upsert_label "area:build" "Local builds, Makefile, latexmk, artifacts, or build scripts" "f9d0c4"
upsert_label "area:documentation" "README, API docs, architecture docs, roadmap, changelog, or migration notes" "0075ca"

# ------------------------------------------------------------
# State and contributor labels
# ------------------------------------------------------------

upsert_label "blocked" "Cannot move forward until another issue, decision, or dependency is resolved" "b60205"
upsert_label "technical-debt" "Cleanup or improvement that reduces future maintenance cost" "fbca04"
upsert_label "breaking-change" "Changes public commands, keys, options, or documented behavior incompatibly" "b60205"
upsert_label "good-first-issue" "Small, well-scoped task suitable for a first contribution" "7057ff"
upsert_label "help-wanted" "Extra input, review, testing, or contribution would be useful" "008672"

echo "Labels created or updated successfully."