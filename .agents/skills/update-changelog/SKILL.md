---
name: update-changelog
description: Write or update the CareerDossierTeX CHANGELOG.md entry for a user-visible change, in the project's one-line house style. Use for a CHANGELOG.md entry.
---

# Write a CHANGELOG entry

Read and follow, in order:

1. `reference.md`, alongside this file
2. `CHANGELOG.md` — the current `[Unreleased]` section, for what is already
   recorded. Take the entry style from `reference.md`, not from the file:
   sections `[0.1.0]`–`[0.8.0]` predate the one-line rule (#518) and are
   deliberately not rewritten, so imitating them reproduces the style it retired.
3. `CONTRIBUTING.md`'s "Update `CHANGELOG.md` when" section

## Procedure

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

## Boundaries

An entry is routine work, made in the same pull request as the change it
records. Retitling `[Unreleased]` for a release, and the release notes, belong
to the `release-notes` skill.
