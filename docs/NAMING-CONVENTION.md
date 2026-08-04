# CareerDossierTeX Naming Conventions

This file defines the naming rules for issues, labels, branches, commits, pull requests, and releases in the `CareerDossierTeX` repository.

The goal is to make the GitHub Project easy to scan and to keep the history consistent.

## 1. Core rule

Use different naming styles for different GitHub objects:

| Object | Convention | Example |
|---|---|---|
| Issue title | `[area] Verb object` | `[resume] Implement the English résumé class` |
| Epic issue title | `[epic] Release version goal` | `[epic] Release v0.1.0 English industry dossier` |
| Branch name | `type/short-description` | `feat/resume-class` |
| Commit message | `type(scope): imperative summary` | `feat(resume): add entry environment` |
| Pull request title | `type(scope): imperative summary` | `docs(api): define v0.1 public API` |
| Label | `type:*` or `area:*` | `type:docs`, `area:resume` |
| Milestone | `version — release name` | `v0.1.0 — English Industry Dossier` |
| Tag | `vX.Y.Z` | `v0.1.0` |

Do not force one convention onto every object. Issues, branches, commits, PRs, and labels serve different purposes.

---

## 2. Issue title convention

Use:

```text
[area] Verb object
```

Examples:

```text
[docs] Inventory current résumé and cover-letter implementations
[docs] Define the v0.1 public API
[core] Implement metadata storage and validation
[theme] Implement LuaLaTeX typography and monochrome tokens
[components] Implement shared header and contact line
[resume] Implement the English résumé class
[letter] Implement the English industry cover-letter class
[test] Establish the shared regression harness
[ci] Build Phase 1 examples in GitHub Actions
[docs] Prepare README, changelog, and release documentation
[release] Publish v0.1.0
```

### Epic issue titles

Use:

```text
[epic] Release vX.Y.Z release goal
```

Example:

```text
[epic] Release v0.1.0 English industry dossier
```

Use lowercase `[epic]` for visual consistency with other bracket prefixes.

Create an epic only for work that genuinely decomposes into several issues. An
issue does not need a parent, and a placeholder epic created so a lone issue has
somewhere to sit only reproduces its milestone. Where an epic exists, its
sub-issue graph is canonical and a body checklist is a rendering of it. See
"Work item structure" in `CONTRIBUTING.md`.

---

## 3. Branch naming convention

Use:

```text
type/short-description
```

Allowed branch types:

```text
feat/
fix/
docs/
test/
ci/
refactor/
release/
chore/
```

Examples:

```text
docs/current-class-inventory
docs/v0.1-api
feat/shared-foundation
feat/resume-class
feat/industry-letter
test/regression-harness
ci/lualatex-build
docs/v0.1-release
release/v0.1.0
```

Rules:

- Use lowercase.
- Use hyphens, not spaces or underscores.
- Keep the name short but specific.
- Match the branch type to the main purpose of the work.
- Do not include issue numbers unless you find them useful later.

---

## 4. Commit message convention

Use a lightweight Conventional Commits style:

```text
type(scope): imperative summary
```

Examples:

```text
docs(api): define v0.1 metadata keys
feat(core): add profile metadata storage
feat(resume): add dossier entry environment
feat(letter): add recipient address block
fix(components): omit separators for empty fields
test(resume): add long URL stress example
ci(build): compile industry examples with LuaLaTeX
refactor(theme): centralize monochrome color tokens
release: prepare v0.1.0
```

### Commit types

Use these types:

```text
feat      New user-facing or maintainer-facing feature
fix       Bug fix
docs      Documentation-only change
test      Tests, examples, smoke tests, or regression checks
ci        GitHub Actions or automation changes
refactor  Code restructuring without changing public behavior
chore     Maintenance that does not fit another type
release   Version, changelog, tag, or release preparation
```

### Scope examples

Use the scope to identify the part of the repository affected:

```text
api
core
i18n
typography
theme
components
resume
letter
examples
build
github
release
```

Rules:

- Write the summary in the imperative mood: `add`, `define`, `fix`, `prepare`.
- Keep the first line short.
- Do not combine unrelated changes in one commit.
- Prefer one coherent change per commit.

---

## 5. Pull request title convention

Use the same style as commit messages:

```text
type(scope): imperative summary
```

Examples:

```text
docs(github): add setup scripts for labels and Phase 1 issues
docs(planning): add Phase 1 planning documents
docs(api): define v0.1 public API
feat(core): add shared metadata foundation
feat(resume): implement English résumé class
feat(letter): implement industry cover-letter class
test(build): establish Phase 1 regression harness
ci(build): compile Phase 1 examples with LuaLaTeX
release: prepare v0.1.0
```

Rules:

- A PR title should describe the whole branch, not every small commit.
- Use `Closes #issue-number` in the PR body when the PR completes an issue.
  Every PR links an issue except a revert, a release chore, or a CI/tooling
  repair; those state the problem, proposal, and acceptance criteria in the body
  instead. See "Work item structure" in `CONTRIBUTING.md`.
- Do not close a large epic from an early implementation PR. Close the focused sub-issue instead.
- Use draft PRs for unfinished branches that need CI or notes.

---

## 6. Label naming convention

Use labels as metadata, not as titles.

### Type labels

Apply exactly one primary type label when possible:

```text
type:feature
type:bug
type:docs
type:test
type:ci
type:refactor
type:release
```

### Area labels

Use one or more area labels when useful:

```text
area:core
area:resume
area:letter
area:cv
area:bibliography
area:i18n
area:typography
area:theme
area:components
area:build
area:documentation
area:agents
```

### State and contributor labels

Use only when needed:

```text
blocked
technical-debt
breaking-change
help-wanted
```

Rules:

- Do not use labels for status. Use the Project `Status` field.
- Do not use labels for priority. Use the Project `Priority` field.
- Do not use labels for release numbers. Use GitHub milestones.
- Do not duplicate information already shown by GitHub fields.

---

## 7. Milestone naming convention

Use:

```text
vX.Y.Z — Release Name
```

Examples:

```text
v0.1.0 — English Industry Dossier
v0.2.0 — Academic Dossier
v0.5.0 — Statements and Customization
v0.6.0 — Calibrated Type Scale and Rhythm
v1.0.0 — Stable Public API
```

Rules:

- Milestones represent releases.
- **Every issue carries a milestone.** It is the field that answers "which
  release", and the Project's `Phase` follows it. A pull request inherits its
  issue's milestone.
- An epic parent is conditional; the milestone is not. See "Work item structure"
  in `CONTRIBUTING.md`.
- Do not create labels like `v0.1.0`; the milestone already tracks this.

---

## 8. Tag and release naming convention

Use semantic version tags:

```text
vX.Y.Z
```

Examples:

```text
v0.1.0
v0.2.0
v1.0.0
```

GitHub Release title:

```text
CareerDossierTeX vX.Y.Z — Release Name
```

Example:

```text
CareerDossierTeX v0.1.0 — English Industry Dossier
```

---

## 9. Project Status convention

Use the Project `Status` field for workflow state:

```text
Backlog
Ready
In Progress
Done
In review
```

Listed in the Project's own option order. Copy the exact string from
`gh project field-list 2 --owner amirhs1`; option lookup is by name, so a
mismatched transcription sets nothing and reports no error.

Meanings:

| Status | Meaning |
|---|---|
| Backlog | Accepted but not ready or not currently scheduled |
| Ready | Defined enough to start |
| In Progress | Active branch or implementation exists |
| Done | Merged, closed, or otherwise completed |
| In review | Pull request is open and awaiting checks or review |

Rules:

- Parent epic can be `In Progress` while the release is active.
- Sub-issues should move individually through the workflow.
- PRs usually correspond to `In review`.
- Merged PRs and closed issues should become `Done`.

---

## 10. Phase numbering convention

Phases group releases into stages of the product plan. They are numbered in
exactly one place:

- The Project `Phase` field is **canonical**. Its options carry a number and a
  short label:

  ```text
  Phase 2 — Academic
  ```

- `docs/ROADMAP.md` **follows** that numbering. Its headings keep their own
  longer form, keyed to the release version:

  ```text
  ## Phase 2: `v0.2.0 — Academic Dossier`
  ```

Rules:

- The two forms differ deliberately. Only the **numbers** must agree; the
  labels need not.
- A dropped release **does not retain a phase number**. Its `docs/ROADMAP.md`
  section stays as a design record but becomes an unnumbered heading, and the
  Project may reuse the freed slot for the next phase. This is what happened to
  `v0.3.0 — Farsi and Bilingual Support`.
- Refer to a dropped phase by name, never by number.
- When adding, dropping, or reordering a phase, change the Project field first,
  then update `docs/ROADMAP.md` and its cross-walk table to match.
- Check `git grep -nE "Phase [0-9]"` after any renumbering: references to
  `Phase 0`, `Phase 1`, and `Phase 2` appear in several files and are stable,
  but any higher number outside `docs/ROADMAP.md` needs review.

---

## 11. Quick decision guide

When creating a new item, ask:

1. Is this a deliverable or task?  
   Use an issue title: `[area] Verb object`.

2. Is this a code/documentation branch?  
   Use a branch name: `type/short-description`.

3. Is this a saved change in Git history?  
   Use a commit message: `type(scope): imperative summary`.

4. Is this a reviewable package of changes?  
   Use a PR title: `type(scope): imperative summary`.

5. Is this category metadata?  
   Use labels: `type:*` and `area:*`.

6. Is this release tracking?  
   Use a milestone: `vX.Y.Z — Release Name`. Every issue gets one.

7. Does this issue belong to a larger effort?  
   Set an epic parent — but only if the effort really spans several issues.
   Otherwise the milestone alone is correct.

8. Is this workflow state?  
   Use the Project `Status` field.

9. Is this a stage of the product plan?  
   Use the Project `Phase` field, and mirror its number in `docs/ROADMAP.md`.

---

## 12. Golden rule

Keep names boring, predictable, and searchable.

A good naming convention should let you understand the repository history without opening every issue, branch, or pull request.
