# CHANGELOG and release-note workflow

This is the canonical repository procedure for writing `CHANGELOG.md` entries
and GitHub Release notes. It applies to every agent.

`CONTRIBUTING.md` says *when* each file must be updated. This document says
*how* to write what goes in them — house style, structure, and the
LaTeX-package details a generic template would miss.

## Authority boundary

Adding or updating a `CHANGELOG.md` entry is routine work: do it in the same
PR as the user-visible change, like any other required doc update.

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

## CHANGELOG.md entries (every user-visible PR)

1. Add or update the entry in the same PR as the user-visible change (see
   `CONTRIBUTING.md`, "Update `CHANGELOG.md` when").
2. Place new entries under `## [Unreleased]`. Release preparation retitles
   that section to `## [X.Y.Z] - YYYY-MM-DD` and opens a fresh empty
   `## [Unreleased]` above it.
3. Use only the categories already in play (`Added`, `Changed`, `Fixed`,
   `Removed`, or `Deprecated`/`Security` when genuinely applicable). One
   `### Category` heading per category in use; do not split one category's
   entries across two blocks. `Deprecate` reads naturally under `Changed`, so
   a `Deprecated` heading is rarely the one to open.

### The shape of an entry

An entry is **one line**. It says what upgrading does and cites its issue;
everything else has another home. This is the [Common
Changelog](https://common-changelog.org) shape (sections 2.4.1, 3.2, 3.4, and
3.6), adopted in #518 after the file drifted to 195 words per entry against
4.9–17.8
for six comparable projects — `l3build`'s entire changelog, 272 entries since
2018, is shorter than one of this project's release sections was.

It applies to every entry, released or not. #518 rewrote all 139 entries in
the file that have a citable issue or pull request, on the ground that the
reasoning a one-line rewrite displaces is already there.
Eight entries in `[0.1.0]` carry no reference at all, and are the one
exception. They record the repository's initial commit of 2026-07-08, which
predates both the issue tracker (issue #1 was opened 2026-07-09) and the
pull-request workflow, so there is nothing to cite. They still follow every
other rule — one line, opening with a verb — and they are invisible to #518's
acceptance command, which checks only entries that cite something. Do not
extend the exception to a new entry.

```markdown
### Added

- Add `numbering=restart|continue` to `CDossierPublications`. ([#355])

### Fixed

- Fix `#` in a profile value truncating the link it appears in. ([#353])
- **Breaking:** Rename `\CDossierSizeTitle` to `\CDossierSizeDocumentTitle`. ([#243])
```

4. **One line, no continuation.** Section 3.6: *"A change should be brief and
   to the point, no more than one line long."* No follow-up paragraphs, no
   sub-bullets, no code blocks, no measurements. At this file's wrap a full
   line carries about twelve words, which is the budget — there is no separate
   word count to argue about.
5. **Open with a present-tense imperative verb** (section 2.4.1), from this
   controlled vocabulary:

   ```text
   Add       Adopt     Allow     Bump      Change    Correct   Demonstrate
   Deprecate Derive    Document  Drop      Extend    Fix       Move
   Reduce    Reject    Remove    Rename    Replace   Report    Require
   Restore   Retune    Scale     Shorten   Split     Stop      Suppress
   Support   Tighten   Validate  Warn
   ```

   It tells the reader what *upgrading* does, and a sentence opening with a
   verb cannot grow into a paragraph. The list is closed on purpose — a
   vocabulary of thirty-two is what keeps "The résumé now…" from creeping
   back — but it is not sacred: add a verb when one is genuinely missing, to
   this list **and** to #518's acceptance command, which repeats it because a
   command cannot cite a document.
6. **Make it self-describing without its category heading** (section 2.4.1):
   "Add
   `numbering` key", not "`numbering` key" under `### Added`. The test is
   whether the line survives being quoted out of context.
7. **Mark a breaking change `**Breaking:**` immediately after the dash**, with
   the verb still capitalised after it — `**Breaking:** Rename …`, not
   `**Breaking:** rename …`, because the verb still opens the sentence. Use it
   when
   it alters a public command, environment, class option, key, or documented
   behaviour incompatibly. This file has no separate top-level "Breaking
   changes" heading; that structure belongs to the GitHub Release body (below).
   `**BREAKING (scope):**` is the retired spelling and survives only on the
   thirty-five shipped entries #518 left untouched, in `[0.1.0]`–`[0.4.0]`;
   every entry #518 rewrote carries the new one.
8. **End with the closing issue**, reference-style: `([#355])`, with the
   matching `[#NNN]: https://github.com/amirhs1/CareerDossierTeX/issues/NNN`
   definition added to the block after that version's section, not at the
   bottom of the file. Where a change closed no issue, cite the **pull
   request** instead and point the definition at `/pull/NNN`; GitHub numbers
   issues and PRs from one sequence, so the citation reads the same. Four
   historical entries do this. A *new* entry always has an issue to cite —
   `CONTRIBUTING.md` "Work item structure" requires one — so this is a
   backfill allowance, not a licence to skip filing. Several when section 3.4
   merges related changes: `([#428], [#439], [#440])`. No commit hashes —
   section 2.4.2 asks for them because section 6.2 writes at release time, and
   an entry written inside its own PR cannot
   know its squash-merge hash.
9. **No author attribution.** Common Changelog carries one per line; this
   project is solo-maintained and the field would be constant.
10. **Send the reasoning to the PR body, and anything a user must *type* to
    `docs/MIGRATION.md`.** Mechanism, measurements, rejected alternatives, and
    scope notes belong in the PR that made the change — permanently readable,
    and correctable. A source edit, an opt-out recipe, or a command belongs in
    `docs/MIGRATION.md`, whose version heading then carries one notice line
    (section 2.3):

    ```markdown
    ## [X.Y.Z] - YYYY-MM-DD

    _If you are upgrading: please see [`docs/MIGRATION.md`](docs/MIGRATION.md)._
    ```

    If an entry's reasoning genuinely has no home, write it into the document
    that owns the behaviour and cite that — do not keep the paragraph here.
    `CHANGELOG.md` is append-only, so a measurement written here can never be
    corrected once it goes stale.
11. **Do not wrap an entry line.** The rest of the file wraps at 76–79 columns;
    an entry does not, or wrapping re-creates the continuation rule 4 forbids.
    Nothing in `make lint` enforces a column limit.
12. **Merge related changes** (section 3.4) and **remove noise** (section 3.2).
    Section 3.4 merges one change spread over several commits — not several
    distinct defects in one area, which stay separate entries because a user
    can hit them separately.

### Release preparation

13. Add the version's own compare-link definition at the very bottom of the
    file (`[X.Y.Z]: .../compare/vPREV...vX.Y.Z`) and repoint `[Unreleased]` at
    `.../compare/vX.Y.Z...HEAD`.
14. **Before** the retitle in step 2, sweep `[Unreleased]` for
    contributor-tooling entries and remove them. See "The tooling sweep" below.

## The tooling sweep (release-preparation time only)

`CONTRIBUTING.md` "Update `CHANGELOG.md` when" is the boundary: an entry earns
its place by being *user-visible*, and a `Makefile` target a contributor is told
to run, a test-harness guard, or a lint script does not. That boundary is not
applied backwards, so a shipped section is annotated rather than rewritten
(#410, #413). `[Unreleased]` is the opposite case — it sits inside the
boundary's own era and is still editable — and the sweep is what keeps a
release from shipping entries the rule says it should not have produced. #414
ran it for `v0.9.0` and removed eleven; without a standing step the next
release accumulates the same backlog.

Run it in this order:

```bash
grep -n 'Contributor tooling only' CHANGELOG.md   # the marker, but not the test
```

1. **Do not trust the marker.** It finds entries that declared themselves; it
   misses one that is tooling-only without carrying it, and #414 found exactly
   one such entry. Read every entry in `[Unreleased]` and apply the
   `CONTRIBUTING.md` test to each: *what* changed, not who ran it. Under the
   one-line rule this is a short read, and rule 12's section 3.2 "remove
   noise" is the same test applied when the entry is written rather than at
   release time.
2. **Confirm the content has a home before deleting it.** A contributor-facing
   target belongs in `CONTRIBUTING.md`, a suite or guard in `docs/TESTING.md`.
   Usually it is already there and nothing is needed; where it is not, write it
   there in the same change. Deleting an entry must not delete the only record
   of the behavior.
3. **Delete the entry's reference-link definitions with it, and only then.**
   Removing an entry can strand a `[#NNN]` definition, and it can equally strand
   a *citation* in a surviving entry whose definition went with the entry
   removed. Nothing in `make lint` covers either; audit the section directly and
   re-check that every `[#NNN]` cited anywhere in the file still resolves.
4. **Leave a citation that survives.** A user-visible entry may legitimately
   cite a tooling issue as part of its reasoning; that is a link to an issue,
   not an entry for it, and it stays.
5. Then `make lint`, which covers the Markdown anchors but not step 3.

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

      `make lint` already asserts that the ten agree *with each other* and that
      the declaring files are exactly `manifest.txt`'s Work list (#258), so a
      bump that missed one file no longer reaches here. What it deliberately
      does not check — because both are false on `main` between releases — is
      that the agreed pair is the release date and the tag about to be cut.
      That half is this checklist item, and it is the only half left.
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

This list is not a report of its own. `AGENTS.md` "Completion report" defines
the one report shape and states, under "How the report formats compose", that
this list is the release payload of its `Test criteria` section. Report it
there, under the single verdict that report carries.

After drafting either document, verify:

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
