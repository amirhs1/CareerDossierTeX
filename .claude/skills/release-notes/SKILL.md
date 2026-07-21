---
name: release-notes
description: Write or update a CareerDossierTeX CHANGELOG.md entry, or draft GitHub Release notes at release-preparation time, following the project's house style and LaTeX-package compatibility checklist.
---

# Write CHANGELOG entries and release notes

Read and follow, in order:

1. `AGENTS.md`
2. `docs/agent-workflows/release-notes.md`
3. `CHANGELOG.md` — existing entries for house style, and the current
   `[Unreleased]` section
4. `docs/naming_conventions.md` (tag, milestone, and release-title naming)
5. `CONTRIBUTING.md`'s "Update `CHANGELOG.md` when" and "Release
   contributions" sections

## Procedure

### Every behavior-changing PR

1. Confirm the change is user-visible: a feature, a behavior change, a fix,
   or a breaking change.
2. Add or update the entry under `## [Unreleased]` in the correct Keep a
   Changelog category (`Added`, `Changed`, `Fixed`, `Removed`, or
   `Deprecated`/`Security` when applicable).
3. Write the entry in user-impact terms and mark a breaking change with a
   bold inline prefix, not a separate heading.
4. Add the `([#NN])` issue citation and its reference-link definition.
5. Confirm optional-field and separator behavior is unaffected, or documented
   if it changed.

### Release preparation only

6. Confirm `CONTRIBUTING.md`'s "Release contributions" checklist is otherwise
   satisfied before drafting release-note text.
7. Retitle `[Unreleased]` to the dated version heading and open a fresh empty
   `[Unreleased]` section above it.
8. Draft the GitHub Release body using the structure and worked examples in
   `docs/agent-workflows/release-notes.md`. Keep it a selective announcement,
   not a restated CHANGELOG.
9. Run the LaTeX-package compatibility checklist (engine support,
   `\ProvidesExpl*` version/date sync, public API changes, output-affecting
   changes, dependency changes, unvalidated-scope disclaimers).
10. Verify and report the outcomes listed in that document's "Verification"
    section, including anything not verified.

## Boundaries

Never tag or publish a release, or run `gh release create`/`gh release edit`
to a non-draft state, without the maintainer's explicit authorization for
that exact release. Drafting the CHANGELOG entry and the release-note text is
routine; tagging and publishing are not.

Do not invent a support claim (ATS, WCAG, PDF/UA, or otherwise) beyond what
`AGENTS.md` and `docs/agent-workflows/release-notes.md` allow, and do not
carry a preview-feature scope note over into general-capability language.
