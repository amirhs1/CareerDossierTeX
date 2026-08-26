---
name: release-notes
description: Write or update a CareerDossierTeX CHANGELOG.md entry, or draft GitHub Release notes at release-preparation time, following the project's house style and LaTeX-package compatibility checklist.
---

# Write CHANGELOG entries and release notes

Read and follow, in order:

1. `AGENTS.md`
2. `reference.md`, alongside this file
3. `CHANGELOG.md` — the current `[Unreleased]` section, for what is already
   recorded. Take the entry style from `reference.md`, not from the file:
   sections `[0.1.0]`–`[0.8.0]` predate the one-line rule (#518) and are
   deliberately not rewritten, so imitating them reproduces the style it retired.
4. `docs/NAMING-CONVENTION.md` (tag, milestone, and release-title naming)
5. `CONTRIBUTING.md`'s "Update `CHANGELOG.md` when" and "Release
   contributions" sections

## Procedure

### Every user-visible PR

1. Confirm the change is user-visible: a feature, a behavior change, a fix,
   or a breaking change.
2. Add or update the entry under `## [Unreleased]` in the correct Keep a
   Changelog category (`Added`, `Changed`, `Fixed`, `Removed`, or
   `Deprecated`/`Security` when applicable).
3. Write it as one line, opening with a present-tense verb, self-describing
   without its heading — `reference.md` "The shape of an entry" is the rule.
   Send the reasoning to the PR body and anything a user must *type* to
   `docs/MIGRATION.md`.
4. Add the `([#NN])` issue citation and its reference-link definition, and
   prefix a breaking change `**Breaking:**` inline, not under a heading.
5. Confirm optional-field and separator behavior is unaffected, or documented
   if it changed.

### Release preparation only

6. Confirm `CONTRIBUTING.md`'s "Release contributions" checklist is otherwise
   satisfied before drafting release-note text.
7. Retitle `[Unreleased]` to the dated version heading and open a fresh empty
   `[Unreleased]` section above it.
8. Draft the GitHub Release body using the structure and worked examples in
   `reference.md`. Keep it a selective announcement, not a restated CHANGELOG.
9. Run the LaTeX-package compatibility checklist (engine support,
   `\ProvidesExpl*` version/date sync, public API changes, output-affecting
   changes, dependency changes, unvalidated-scope disclaimers).
10. Verify and report the outcomes listed in that document's "Verification"
    section, including anything not verified.

## Boundaries

Publishing a release is reserved by `AGENTS.md` rule 11 (Maintainer authority),
which is not restated here. In this skill that reservation reaches tagging and
any `gh release create` or `gh release edit` that leaves the release in a
non-draft state. Drafting the CHANGELOG entry and the release-note text is
routine; tagging and publishing are not.

Do not invent a support claim (ATS, WCAG, PDF/UA, or otherwise) beyond what
`AGENTS.md` and `reference.md` allow, and do not carry a preview-feature scope
note over into general-capability language.
