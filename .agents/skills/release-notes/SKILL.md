---
name: release-notes
description: Prepare CHANGELOG.md for a CareerDossierTeX release and draft the GitHub Release notes, following the project's house style and LaTeX-package compatibility checklist. Use at release-preparation time.
---

# Prepare a release's CHANGELOG and notes

Read and follow, in order:

1. `AGENTS.md`
2. `reference.md`, alongside this file
3. `.agents/skills/update-changelog/reference.md`, for the shape of an entry
4. `CHANGELOG.md` — the current `[Unreleased]` section
5. `CONTRIBUTING.md`'s "Release contributions" section

## Procedure

1. Confirm `CONTRIBUTING.md`'s "Release contributions" checklist is otherwise
   satisfied before drafting release-note text.
2. Sweep `[Unreleased]` for contributor-tooling entries, as `reference.md`
   ("The tooling sweep (release-preparation time only)") says.
3. Retitle `[Unreleased]` to the dated version heading, open a fresh empty
   `[Unreleased]` section above it, and update the compare links, as
   `reference.md` ("CHANGELOG.md at release time") says.
4. Draft the GitHub Release body using the structure and worked examples in
   `reference.md`. Keep it a selective announcement, not a restated CHANGELOG.
   Tags are `vX.Y.Z`, and a release is titled
   `CareerDossierTeX vX.Y.Z — Release Name`, after its milestone
   `vX.Y.Z — Release Name`.
5. Run the LaTeX-package compatibility checklist (engine support,
   `\ProvidesExpl*` version/date sync, public API changes, output-affecting
   changes, dependency changes, unvalidated-scope disclaimers).
6. Verify and report the outcomes listed in that document's "Verification"
   section, including anything not verified.

## Boundaries

Publishing a release is reserved by `AGENTS.md` ("Git"), which is not restated
here. In this skill that reservation reaches tagging and
any `gh release create` or `gh release edit` that leaves the release in a
non-draft state. Drafting the release-note text is routine; tagging and
publishing are not.

Do not invent a support claim (ATS, WCAG, PDF/UA, or otherwise) beyond what
`AGENTS.md` and `reference.md` allow, and do not carry a preview-feature scope
note over into general-capability language.
