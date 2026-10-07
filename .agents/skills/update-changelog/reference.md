# CHANGELOG entry workflow

This is the canonical repository procedure for writing `CHANGELOG.md` entries.
It applies to every agent. `CONTRIBUTING.md` says *when* the file must be
updated; this document says *how* to write an entry. Release-time work on the
file, and the GitHub Release notes, belong to the `release-notes` skill.

Adding or updating an entry is routine work: do it in the same PR as the
user-visible change, like any other required doc update.

- **`CHANGELOG.md` is the record.** Complete, cumulative, categorized. Every
  user-visible change gets an entry, under the Keep a Changelog categories
  already in use in this file: `Added`, `Changed`, `Fixed`, `Removed` (plus
  the standard `Deprecated` and `Security` when one applies).

## CHANGELOG.md entries (every user-visible PR)

1. Add or update the entry in the same PR as the user-visible change (see
   `CONTRIBUTING.md`, "Update `CHANGELOG.md` when").
2. Place new entries under `## [Unreleased]`. Release preparation, in the
   `release-notes` skill, retitles that section to `## [X.Y.Z] - YYYY-MM-DD`
   and opens a fresh empty `## [Unreleased]` above it.
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
   vocabulary of thirty-two is what keeps "The resume now…" from creeping
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
   changes" heading; that structure belongs to the GitHub Release body, which
   the `release-notes` skill drafts.
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
   know its merge-commit hash.
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
