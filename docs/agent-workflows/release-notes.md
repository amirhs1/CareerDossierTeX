# CHANGELOG and release-note workflow

This is the canonical repository procedure for writing `CHANGELOG.md` entries
and GitHub Release notes. It applies to Codex and Claude Code.

`CONTRIBUTING.md` says *when* each file must be updated. This document says
*how* to write what goes in them — house style, structure, and the
LaTeX-package details a generic template would miss.

## Authority boundary

Adding or updating a `CHANGELOG.md` entry is routine work: do it in the same
PR as the behavior change, like any other required doc update.

Drafting GitHub Release note text is also routine work once
`CONTRIBUTING.md`'s "Release contributions" checklist is otherwise satisfied —
for example in a release-preparation PR.

Tagging and publishing the release is not. Creating a tag, pushing it, and
running `gh release create` (or publishing a drafted release) remain
maintainer-only actions. An agent may prepare the release-note text and stop
there unless the maintainer explicitly authorizes tagging and publishing.

## Two documents, two jobs

- **`CHANGELOG.md` is the record.** Complete, cumulative, categorized. Every
  user-visible change gets an entry, under the Keep a Changelog categories
  already in use in this file: `Added`, `Changed`, `Fixed`, `Removed` (plus
  the standard `Deprecated` and `Security` when one applies).
- **The GitHub Release is the announcement.** Selective and point-in-time. It
  answers three questions fast: what changed, who is affected, what must I do.
  It never reproduces the CHANGELOG — it links to it.

Test each release-note sentence against: *would a reader act differently
without it?* If no, it belongs only in the CHANGELOG.

Size notes by disruption, not by effort. `v0.1.0`–`v0.2.1` averaged roughly
127 words; even the breaking `v0.4.0` release, with a full migration path,
shipped at 350. Treat significantly more than that as a signal to cut, not a
target — when the release notes start reproducing the CHANGELOG, the "see the
CHANGELOG" link has gone decorative.

## CHANGELOG.md entries (every behavior-changing PR)

1. Add or update the entry in the same PR as the behavior change (see
   `CONTRIBUTING.md`, "Update `CHANGELOG.md` when").
2. Place new entries under `## [Unreleased]`. Release preparation retitles
   that section to `## [X.Y.Z] - YYYY-MM-DD` and opens a fresh empty
   `## [Unreleased]` above it.
3. Use only the categories already in play (`Added`, `Changed`, `Fixed`,
   `Removed`, or `Deprecated`/`Security` when genuinely applicable). One
   `### Category` heading per category in use; do not split one category's
   entries across two blocks.
4. Write in user-impact terms, not implementation terms: "Added `--dry-run`
   support" beats "Refactored CLI executor."
5. Mark a breaking change with a bold inline prefix inside its `Added` or
   `Changed` entry — for example `**BREAKING (toolchain): ...**` — the way
   the `v0.4.0` LuaLaTeX entry does it. This file has no separate top-level
   "Breaking changes" heading; that structure belongs to the GitHub Release
   body instead (below).
6. Cite the closing issue(s) in parentheses at the end of the bullet, e.g.
   `([#91])`. These are markdown reference-style links, not GitHub
   autolinks — add the matching `[#NN]: https://github.com/amirhs1/CareerDossierTeX/issues/NN`
   definition. Existing files place that block right after the version
   section that cites it, not at the bottom of the file.
7. Longer or higher-stakes entries may add unlabeled follow-up paragraphs
   after the lead bullet — what changed, why, and an explicit scope note
   (e.g. "this changes rendered output; no class, option, key, or command
   changed"). See the `v0.4.0` LuaLaTeX and CV-folio entries for the shape.
8. At release-preparation time, add the version's own compare-link
   definition at the very bottom of the file (`[X.Y.Z]: .../compare/vPREV...vX.Y.Z`)
   and repoint `[Unreleased]` at `.../compare/vX.Y.Z...HEAD`.

## GitHub Release notes (release-preparation time only)

Structure — all sections after the framing sentence are optional; omit any
that are empty rather than writing "None":

1. One plain framing sentence (no heading, no blockquote): what the release
   does and its main benefit.
2. `### Breaking` — only if applicable. Put it first: a reader should not
   have to infer breaking changes from a commit list. Each bullet states
   what broke, the one-line fix, and an issue reference.
3. `### Highlights` — terse, lowercase-leading bullets, most user-visible
   change first, issue references in parentheses.
4. `### Upgrade note` — only when there is actionable migration work. Link
   `docs/MIGRATION.md` for detail instead of inlining the migration steps.
5. A short scope/caveat paragraph when the release needs one — for example
   what a preview feature does and does not validate. See `v0.4.0`'s "Scope
   of the tagged-PDF preview" paragraph.
6. A `Supported: <engine> · <language> · <paper size> · <theme>` line, kept
   in sync with `README.md`'s support table.
7. `See the [CHANGELOG](.../CHANGELOG.md) for full details.`, linked at the
   release tag, not `main`.
8. `**Full changelog:** <compare link>` from the previous tag to this one.

Two worked examples already live in this repository's release history —
read them before drafting a new one rather than starting from the generic
template below:

```bash
gh release view v0.2.0 --json body -q .body   # small additive release
gh release view v0.4.0 --json body -q .body   # breaking release, full structure
```

## LaTeX-package compatibility checklist

Verify and reflect the following before a release-preparation PR is
considered ready for the maintainer, and again before any tag is authorized:

- [ ] `\ProvidesExplPackage`/`\ProvidesExplClass` date and version match the
      release date and tag in every `.sty`/`.cls` file:
      `grep -n "ProvidesExpl" *.sty *.cls`
- [ ] The supported engine statement is current (today: LuaLaTeX only;
      XeLaTeX and pdfLaTeX are unsupported and produce a fatal error — see
      `careerdossier-typography.sty`).
- [ ] Every added, renamed, or removed public command, environment, class
      option, or `l3keys` key is listed, with a migration snippet for any
      rename, matching `docs/MIGRATION.md`.
- [ ] Every output-affecting change (spacing, fonts, page layout, folio or
      running-header text, hyperlink behavior, PDF metadata or tagging
      defaults) is called out even when compilation still succeeds.
- [ ] New minimum dependency versions or newly required packages/classes are
      stated.
- [ ] Known incompatibilities or unvalidated scope are stated explicitly, not
      implied — do not let a preview feature read as a general capability
      (`AGENTS.md`'s "No unsupported claims" rule: no ATS, WCAG, or PDF/UA
      conformance claim without validation backing it).
- [ ] Distribution channel is accurate: this toolkit is not currently
      distributed via CTAN, TeX Live, or MiKTeX package managers; note this
      only if it changes.

## Verification

After drafting either document, verify and report:

- the `CHANGELOG.md` entry exists under the correct version heading and
  category, with issue reference definitions added;
- `\ProvidesExpl*` date/version lines are synchronized across every
  `.sty`/`.cls` file touched by the release;
- `README.md`'s status banner and support table are updated if support
  changed;
- `docs/MIGRATION.md` is updated if a public rename or incompatibility
  exists;
- the GitHub Release draft's word count and section list;
- what was not verified (for example, no build or log inspection performed
  in this pass).

## Appendix: gh command reference

Drafting and, once explicitly authorized, publishing:

```bash
# Read past release bodies as worked examples
gh release view vX.Y.Z --json body -q .body

# Compare link between two tags (for the "Full changelog" line)
# https://github.com/amirhs1/CareerDossierTeX/compare/vPREV...vX.Y.Z

# Maintainer-authorized only: create a draft release from a notes file
gh release create vX.Y.Z --draft --title "CareerDossierTeX vX.Y.Z — Release Name" \
  --notes-file <notes.md>

# Maintainer-authorized only: publish a previously drafted release
gh release edit vX.Y.Z --draft=false
```

Release titles follow `docs/NAMING-CONVENTION.md`:
`CareerDossierTeX vX.Y.Z — Release Name`.
