# Tonight's Execution Checklist

Date:

```text
July 8, 2026
```

Goal:

```text
Publish or prepare v0.1.0 with a working English résumé and cover letter.
```

## Scope rule

Tonight's release includes only:

- XeLaTeX;
- English;
- Letter paper;
- monochrome theme;
- résumé;
- industry cover letter;
- shared profile;
- basic examples;
- basic CI;
- essential documentation.

Move everything else to later milestones.

## Part A: repository planning

### 1. Create milestones

- [ ] `v0.1.0 — English Industry Dossier`
- [ ] `v0.2.0 — Academic Dossier`
- [ ] `v0.3.0 — Farsi and Bilingual Support`
- [ ] `v0.4.0 — Statements and Customization`
- [ ] `v1.0.0 — Stable Public API`

### 2. Create labels

- [ ] Type labels
- [ ] Area labels
- [ ] `blocked`
- [ ] `technical-debt`
- [ ] `breaking-change`

### 3. Create the GitHub Project

- [ ] Project named `CareerDossierTeX Development`
- [ ] Status field
- [ ] Phase field
- [ ] Priority field
- [ ] Size field
- [ ] Tonight board view
- [ ] All Work table view
- [ ] Roadmap view
- [ ] Auto-add repository issues and PRs

### 4. Create Phase 1 parent issue and sub-issues

- [ ] Release epic
- [ ] Inventory issue
- [ ] API issue
- [ ] Core metadata issue
- [ ] Typography/theme issue
- [ ] Components issue
- [ ] Résumé issue
- [ ] Letter issue
- [ ] Add focused `tests/` acceptance criteria to every implementation issue
- [ ] Test-harness issue only if shared infrastructure needs separate work
- [ ] CI issue
- [ ] Documentation issue
- [ ] Release issue

## Part B: prepare the repository

### 5. Preserve existing work

- [ ] Compile the current best résumé.
- [ ] Compile the current best cover letter.
- [ ] Save the PDFs.
- [ ] Save or inspect logs.
- [ ] Record current public commands.
- [ ] Record current dependencies.
- [ ] Do not delete old classes yet.

### 6. Add documentation skeleton

- [ ] `docs/ARCHITECTURE.md`
- [ ] `docs/ROADMAP.md`
- [ ] `docs/API.md`
- [ ] `docs/MIGRATION.md`
- [ ] `CONTRIBUTING.md`
- [ ] `CHANGELOG.md`

## Part C: implementation branches

### 7. API branch

```bash
git switch main
git pull --ff-only
git switch -c docs/v0.1-api
```

- [ ] Define profile keys.
- [ ] Define letter keys.
- [ ] Define public commands.
- [ ] Define required fields.
- [ ] Define defaults.
- [ ] Open PR.
- [ ] Merge after review.

### 8. Shared foundation branch

```bash
git switch main
git pull --ff-only
git switch -c feat/shared-foundation
```

- [ ] Engine check.
- [ ] Metadata storage.
- [ ] Required-field validation.
- [ ] English label abstraction.
- [ ] Semantic typography.
- [ ] Monochrome theme.
- [ ] Shared header.
- [ ] Contact separator handling.
- [ ] Backfill committed base, typography/theme, and component regression tests
      under `tests/` before or with the next production change.
- [ ] Open PR and run local examples.
- [ ] Merge.

### 9. Résumé branch

```bash
git switch main
git pull --ff-only
git switch -c feat/resume-class
```

- [ ] Implement geometry.
- [ ] Implement section command.
- [ ] Implement entry environment.
- [ ] Implement compact itemize.
- [ ] Add focused résumé tests under `tests/` before or alongside implementation.
- [ ] Add résumé example.
- [ ] Compile with XeLaTeX.
- [ ] Inspect PDF and log.
- [ ] Check text extraction.
- [ ] Open PR.
- [ ] Merge.

### 10. Letter branch

```bash
git switch main
git pull --ff-only
git switch -c feat/industry-letter
```

- [ ] Implement recipient data.
- [ ] Implement date.
- [ ] Implement subject.
- [ ] Implement salutation and closing.
- [ ] Reuse profile and letterhead.
- [ ] Add focused letter tests under `tests/` before or alongside implementation.
- [ ] Add letter example.
- [ ] Compile with XeLaTeX.
- [ ] Open PR.
- [ ] Merge.

## Part D: automation and release

### 11. CI branch

```bash
git switch main
git pull --ff-only
git switch -c ci/xelatex-build
```

- [ ] Add build workflow.
- [ ] Run every applicable suite under `tests/`.
- [ ] Compile both examples.
- [ ] Upload PDFs and logs.
- [ ] Open PR.
- [ ] Confirm workflow passes.
- [ ] Merge.

### 12. Protect `main`

Only after the build check has succeeded:

- [ ] Require pull requests.
- [ ] Require the build check.
- [ ] Require conversation resolution.
- [ ] Block force pushes.
- [ ] Block branch deletion.
- [ ] Do not require outside approval while working alone.

### 13. Release preparation

- [ ] README quick start.
- [ ] Current support clearly stated.
- [ ] Future features clearly marked.
- [ ] `CHANGELOG.md` updated.
- [ ] Version strings set to `0.1.0`.
- [ ] Both examples compile locally.
- [ ] CI passes on `main`.
- [ ] Working tree clean.

### 14. Tag and release

```bash
git switch main
git pull --ff-only
git tag -a v0.1.0 -m "Release v0.1.0: English industry dossier"
git push origin v0.1.0
```

- [ ] Create GitHub Release.
- [ ] Attach résumé PDF.
- [ ] Attach cover-letter PDF.
- [ ] Publish release notes.
- [ ] Close milestone.
- [ ] Move release epic to Done.

## Minimum fallback release

When implementation time is limited, protect quality by reducing scope, not by pretending incomplete features work.

Minimum acceptable `v0.1.0`:

- working English résumé;
- working English cover letter;
- shared profile;
- focused tests for every included behavior, committed as each feature lands;
- local build instructions;
- CI compiling both examples;
- honest README;
- Git tag and release.

Move extra options, themes, typography presets, and genuinely optional test
infrastructure to `v0.1.1` or `v0.2.0`. Do not defer a focused test that is
needed to prove behavior included in `v0.1.0`; reduce the feature scope instead.
