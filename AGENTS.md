# AGENTS.md — CareerDossierTeX operating contract

This file contains stable, repository-wide instructions for coding agents. Keep it
high-signal. Put detailed naming and contribution procedures in the canonical
repository documentation rather than duplicating them here.

## Repository purpose

`CareerDossierTeX` is a reusable XeLaTeX toolkit for producing consistent career
documents from shared profile data. It is intended to provide modular `.sty`
packages and `.cls` classes with a small documented public API.

- Maintainer: Amir Sadeghi
- License: LPPL v1.3c, maintenance status `maintained`
- Git policy: source text only; generated PDFs and LaTeX build files are artifacts
- Current release goal: confirm from the active milestone before starting work

## Establish the current state first

At the start of a task:

1. Inspect the current branch, `git status --short`, and recent commits.
2. Inspect the relevant files and available build/test commands; do not assume a
   planned path already exists.
3. Identify the focused issue or PR, its parent epic, its milestone, and relevant
   GitHub Project fields when available.
4. Confirm that the requested work belongs to the active milestone.
5. State material assumptions and keep the change limited to the requested scope.

The live worktree and current GitHub issue, PR, milestone, and Project state take
precedence over stale prose. If sources conflict, report the conflict instead of
silently choosing a convenient interpretation.

## Sources of truth

Use these canonical sources when they exist:

- `README.md` — currently supported behavior and user-facing status
- `CONTRIBUTING.md` — contribution, branch, test, PR, CI, and release workflow
- `docs/naming_conventions.md` — names for issues, branches, commits, PRs,
  labels, milestones, tags, and releases
- `docs/API.md` — public commands, keys, defaults, warnings, and errors
- `docs/ARCHITECTURE.md` — module boundaries and dependency direction
- `docs/ROADMAP.md` — release scope, phases, and non-goals
- `docs/MIGRATION.md` — public renames and incompatible changes
- `CHANGELOG.md` — user-visible changes
- `scripts/setup-labels.sh` — label definitions

`docs/planning/` is temporary and noncanonical. Do not create new dependencies on
it. When it is removed, update remaining references in the same change.

## Non-negotiable rules

1. **Supported engine:** use XeLaTeX for the active Phase 1 scope. Unsupported
   engines must receive a clear error. Do not add partial engine support without
   defining, documenting, and testing it.
2. **Verification honesty:** never claim a build, test, CI run, visual check, or
   accessibility check passed unless it actually ran in this session or the user
   supplied the result.
3. **Scope discipline:** do not implement postponed features as current. Put
   out-of-scope ideas in a proposed backlog issue or follow-up note.
4. **Module ownership:** place behavior in the module that owns the concern.
   Avoid duplicated rendering logic and cross-layer layout code.
5. **Optional fields:** construct a list of present fields, then place separators
   between items. Missing values must not leave stray separators or whitespace.
6. **Docs with behavior:** update affected documentation in the same change.
   The README and API docs may describe only behavior that works.
7. **Source-only Git:** do not commit routine build output or example PDFs.
   Keep `.gitignore` intact unless a reviewed policy change requires otherwise.
8. **Dependencies and assets:** do not add packages, fonts, images, actions, or
   other third-party assets without checking necessity, maintenance, licensing,
   portability, and security.
9. **No conformance claims without evidence:** do not claim ATS compatibility,
   WCAG conformance, PDF/UA conformance, or broad accessibility based only on
   appearance or successful compilation.

## Target module ownership

Apply this map when the corresponding files exist. Until then, follow the focused
issue and current repository structure rather than creating the full target
architecture incidentally.

- `careerdossier-base.sty` — `\CDossierSetup`, metadata storage/access,
  shared keys, and required-field validation; no layout or styling
- `careerdossier-i18n.sty` — English labels and a small language abstraction;
  no Farsi/RTL in Phase 1 and no hard-coded class labels
- `careerdossier-typography.sty` — engine detection, `fontspec`, portable fonts,
  and semantic text roles; no colors or geometry
- `careerdossier-theme.sty` — semantic monochrome color, rule, and link tokens;
  no fonts or geometry
- `careerdossier-components.sty` — identity block, contact line, separators,
  link wrappers, and reusable entry primitives; no page geometry
- `careerdossier-resume.cls` — Letter geometry, sections, entries, and compact lists
- `careerdossier-letter.cls` — industry-letter geometry, recipient block,
  salutation, closing, and letterhead

Before editing, identify the owning module and affected public API.

## Code and API conventions

- Public commands and environments use the `CDossier` prefix.
- Private LaTeX3 names use
  `\__cdossier_<module>_<action>:<signature>`.
- Prefer `l3keys` and modern kernel or `xparse` interfaces for structured APIs.
- Reject unsupported options clearly; do not accept and ignore them.
- Prefer semantic commands, grouped local formatting, explicit diagnostics, and
  readable implementation over clever expansion tricks.
- Keep private commands out of examples and public documentation.
- Significant public API changes require proposed syntax, an example,
  compatibility analysis, acceptance criteria, tests, documentation, and the
  correct milestone before implementation.

## Default work sequence

1. **Understand:** inspect the relevant issue, code, docs, tests, and CI.
2. **Plan:** identify owned modules, public-API impact, tests, documentation, and
   project-management implications.
3. **Implement:** make the smallest coherent change; preserve unrelated work.
4. **Verify:** run the narrowest relevant checks first, then the supported suite
   when execution is available.
5. **Review:** inspect the complete diff, generated files, logs, PDF output when
   layout changed, and documentation consistency.
6. **Report:** state what changed, what ran, exact outcomes, what was not
   verified, and what the maintainer should review.

Ask a focused question only for a material product, scope, visual-design, release,
or destructive-action decision that cannot be resolved from the repository.

## Build and test

Prefer repository-owned commands in the current `Makefile`, CI workflow, or
`CONTRIBUTING.md`. Do not invent a passing command. When the documented example
exists, the baseline form is:

```bash
latexmk -xelatex -interaction=nonstopmode -halt-on-error \
  examples/industry/resume-english.tex
```

For affected behavior, cover the relevant parts of this matrix:

- valid résumé
- valid industry letter
- missing required `name` with a clear actionable error
- missing optional `phone` and `website` without stray separators
- long URL or contact field
- two-page résumé
- text extraction and logical reading order
- unsupported-engine error
- both classes after changes to shared packages

Inspect logs for LaTeX errors, undefined control sequences, emergency stops,
overfull boxes, missing glyphs, font substitutions, and unresolved references.
For layout changes, inspect rendered pages, page breaks, clipping, links, contact
lines, and print/grayscale behavior. Clean generated files after local checks.

If a tool or dependency is unavailable, report that limitation and the exact
checks that remain.

## Design, fonts, color, and accessibility

Treat design changes as engineering decisions. Record the objective, constraints,
options considered, recommendation, and trade-offs.

### Typography

- Prefer portable, actively maintained, appropriately licensed fonts available
  through the supported TeX environment.
- Verify required weights/styles, glyph coverage, small-size legibility,
  text extraction, and fallback behavior.
- Use semantic typography roles rather than scattered direct font commands.
- Do not commit font binaries or change the font stack without explicit approval
  and a license review.

### Color and visual hierarchy

- Phase 1 is monochrome unless the active milestone explicitly changes scope.
- Use semantic tokens rather than literal colors throughout classes/components.
- Maintain at least 4.5:1 contrast for normal text and 3:1 for large text.
- Do not use color as the only way to communicate meaning.
- Check grayscale/print output and avoid rules or text weights that disappear at
  ordinary print and screen sizes.

### Accessibility baseline

- Preserve a logical source and extracted-text reading order.
- Keep text selectable/searchable; avoid text rendered as graphics.
- Use meaningful headings, link text, and non-color cues.
- Check long links, line wrapping, keyboard-usable hyperlink targets where
  applicable, and readable document metadata when implemented.
- Treat text extraction as a baseline check, not proof of full accessibility.
- If tagged PDF or PDF/UA enters scope, follow the current LaTeX Tagged PDF
  guidance, run an appropriate validator, document known limitations, and claim
  conformance only after validation.

## Git, GitHub Project, milestones, and releases

Use `docs/naming_conventions.md` for all names.

- Never commit or push directly to `main`.
- Keep one focused issue per meaningful branch where practical.
- Use milestones for releases, labels for category/area, and GitHub Project
  fields for workflow metadata. Do not duplicate Status, Priority, or version in
  labels.
- Typical Project progression:
  `Backlog → Ready → In progress → In review → Done`.
- A branch normally moves the focused issue to `In progress`; an open PR maps to
  `In review`; a merged PR or completed issue maps to `Done`.
- Keep the parent epic open and `In progress` until its release definition of
  done is satisfied.
- Read GitHub metadata freely. Before creating or editing issues, milestones,
  labels, Project fields, releases, or other remote metadata, show the proposed
  change and obtain explicit approval unless the current request authorizes that
  exact action.

### Commit and PR approval gates

- Before committing, show `git status --short`, the reviewed diff or a precise
  diff summary, tests run and results, staged files, and the complete proposed
  commit message. Obtain the maintainer's final explicit approval.
- Stage only approved files. Recheck the commit message after amendments.
- Before opening a PR, show head/base branches and the proposed title/body.
  Obtain separate final explicit approval.
- Do not merge. The maintainer owns merges.
- Do not add agent/tool prefixes to commit or PR titles.
- Use the agent's configured native attribution. Preserve at most one attribution
  trailer and show it as part of the proposed commit message; do not hard-code a
  model name that may become stale.

PR bodies should include a summary, the focused closing issue reference, change
list, public-API impact, tests and real results, visual/accessibility checks when
relevant, and follow-up work. Use draft PRs for incomplete work.

## CI/CD and repository security

For GitHub Actions changes:

- run supported builds on pull requests and pushes to `main`
- use least-privilege `GITHUB_TOKEN` permissions
- pin third-party actions to full commit SHAs and record the human-readable
  release in a comment
- avoid privileged triggers that execute untrusted pull-request code
- never print, persist, or commit secrets
- keep CI commands reproducible locally where practical
- upload useful PDFs/logs as artifacts rather than committing them
- inspect failed job logs before proposing a fix
- do not require a new branch-protection check until it has passed successfully

Do not publish a tag or release until the release-preparation PR is merged and
the milestone's release criteria are satisfied.

## Documentation and licensing

Update only the docs affected by the behavior:

- public API/default/error changes → `docs/API.md`
- module/dependency changes → `docs/ARCHITECTURE.md`
- phase or release-boundary changes → `docs/ROADMAP.md`
- incompatible public changes → `docs/MIGRATION.md`
- user-visible changes → `CHANGELOG.md`

Keep the official `LICENSE` text unchanged. Add the required project copyright,
license, maintenance-status, and maintainer notice to new `.cls` and `.sty`
files. Update `manifest.txt` when the LPPL Work file set changes. Verify
third-party code, fonts, images, and other assets are license-compatible.

## Completion checklist

Before finishing, confirm:

- the change belongs to the owning module and active milestone
- affected examples and negative cases were actually tested, or limitations stated
- optional fields leave no stray separators
- no unsupported or postponed feature was presented as current
- logs and rendered output were inspected when relevant
- accessibility/design claims match the checks performed
- no generated artifact, secret, or unapproved dependency is staged
- canonical docs and changelog were updated when required
- the final response separates completed work from unverified work
