# Milestones, Labels, and Issues

## 1. Milestones represent releases

Create these milestones.

### `v0.1.0 — English Industry Dossier`

Due:

```text
July 11, 2026
```

Scope:

- English résumé;
- English industry cover letter;
- shared profile;
- XeLaTeX;
- monochrome theme;
- CI build;
- documentation;
- release.

### `v0.2.0 — Academic Dossier`

Scope:

- academic CV;
- academic letter family;
- bibliography and Biber integration;
- multi-page behavior;
- Scholar and ORCID;
- regression tests.

### `v0.3.0 — Farsi and Bilingual Support`

Scope:

- Farsi;
- bilingual English–Farsi;
- RTL layout;
- translated fixed labels;
- Farsi fonts;
- mixed-direction tests.

### `v0.4.0 — Statements and Customization`

Scope:

- statement class;
- A4;
- color and print themes;
- font presets;
- more customization.

### `v1.0.0 — Stable Public API`

Scope:

- API stability;
- complete manual;
- Overleaf release ZIP;
- migration policy;
- full supported build matrix.

Milestones can contain issues and pull requests and show completion progress.

Official documentation:

- https://docs.github.com/issues/using-labels-and-milestones-to-track-work/about-milestones

## 2. Label taxonomy

Keep labels small and predictable.

### Type labels

```text
type:feature
type:bug
type:docs
type:test
type:ci
type:refactor
type:release
```

Apply exactly one primary type label when possible.

### Area labels

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
```

An issue may have more than one area label when the overlap is real.

### State and contributor labels

```text
blocked
technical-debt
breaking-change
help-wanted
```

Do not use labels for:

- status;
- priority;
- release number.

Those belong to Project fields and milestones.

## 3. Parent issue for Phase 1

Create:

```text
[EPIC] Release v0.1.0 English industry résumé and cover letter
```

Suggested body:

```markdown
## Goal

Publish the first usable CareerDossierTeX release containing an English
industry résumé and matching cover-letter class.

## Included

- XeLaTeX
- English
- Letter paper
- monochrome theme
- shared profile metadata
- résumé class
- industry letter class
- examples
- CI build
- documentation
- GitHub Release

## Excluded

- academic CV
- bibliography
- Farsi and bilingual support
- statement class
- A4 and color themes

## Definition of done

- [ ] All Phase 1 sub-issues are closed.
- [ ] CI passes on `main`.
- [ ] Both example PDFs compile.
- [ ] README and API documentation match the implementation.
- [ ] Tag and release `v0.1.0` are published.
```

Assign:

```text
Milestone: v0.1.0 — English Industry Dossier
Phase: Phase 1 — Industry
Priority: P0
Size: L
```

## 4. Phase 1 sub-issues

Use GitHub sub-issues rather than placing the entire release inside one checklist.

Official documentation:

- https://docs.github.com/issues/tracking-your-work-with-issues/using-issues/adding-sub-issues

### Issue 1

```text
[docs] Inventory current résumé and cover-letter implementations
```

Labels:

```text
type:docs
type:refactor
area:resume
area:letter
```

Acceptance criteria:

- [ ] Best résumé baseline identified.
- [ ] Best letter baseline identified.
- [ ] Reference PDFs compiled and saved locally or as artifacts.
- [ ] Public commands inventoried.
- [ ] Dependencies inventoried.
- [ ] Duplicate code identified.
- [ ] Migration table started.

### Issue 2

```text
[docs] Define the v0.1 public API
```

Labels:

```text
type:docs
area:core
area:documentation
```

Acceptance criteria:

- [ ] Profile keys documented.
- [ ] Letter keys documented.
- [ ] Commands and environments documented.
- [ ] Required fields documented.
- [ ] Defaults documented.
- [ ] Unsupported features clearly excluded.

### Issue 3

```text
[core] Implement metadata storage and validation
```

Labels:

```text
type:feature
area:core
```

Acceptance criteria:

- [ ] `\CDossierSetup` exists.
- [ ] Required `name` is validated.
- [ ] Optional fields can be tested.
- [ ] Fields can be rendered safely.
- [ ] Errors are actionable.

### Issue 4

```text
[theme] Implement XeLaTeX typography and monochrome tokens
```

Labels:

```text
type:feature
area:typography
area:theme
```

Acceptance criteria:

- [ ] pdfLaTeX receives a clear error.
- [ ] XeLaTeX loads portable fonts.
- [ ] Semantic typography roles exist.
- [ ] Semantic monochrome colors exist.
- [ ] Links remain readable in print.

### Issue 5

```text
[components] Implement shared header and contact line
```

Labels:

```text
type:feature
area:components
```

Acceptance criteria:

- [ ] Name and headline render.
- [ ] Contact fields render as links where appropriate.
- [ ] Missing optional fields leave no duplicate separators.
- [ ] Components are reusable by résumé and letter.

### Issue 6

```text
[resume] Implement the English résumé class
```

Labels:

```text
type:feature
area:resume
```

Acceptance criteria:

- [ ] Letter paper geometry implemented.
- [ ] `\CDossierSection` implemented.
- [ ] `CDossierEntry` implemented.
- [ ] `CDossierItemize` implemented.
- [ ] Compact layout is readable.
- [ ] Page numbers are disabled by default.
- [ ] Text extraction order is logical.

### Issue 7

```text
[letter] Implement the English industry cover-letter class
```

Labels:

```text
type:feature
area:letter
```

Acceptance criteria:

- [ ] Recipient block implemented.
- [ ] Date, subject, salutation, and closing implemented.
- [ ] Shared profile and letterhead work.
- [ ] One-page and two-page prose page-breaking are acceptable.

### Issue 8

```text
[test] Add Phase 1 examples and smoke tests
```

Labels:

```text
type:test
area:resume
area:letter
area:build
```

Acceptance criteria:

- [ ] Shared profile example added.
- [ ] Résumé example added.
- [ ] Cover-letter example added.
- [ ] Missing-name test added.
- [ ] Missing-optional-field test added.
- [ ] Long-link test added.
- [ ] Text extraction command documented.

### Issue 9

```text
[ci] Build Phase 1 examples in GitHub Actions
```

Labels:

```text
type:ci
area:build
```

Acceptance criteria:

- [ ] Workflow runs on pull requests.
- [ ] Workflow runs on pushes to `main`.
- [ ] Résumé compiles.
- [ ] Letter compiles.
- [ ] PDFs and logs upload as artifacts.
- [ ] Failed compilation fails the check.

### Issue 10

```text
[docs] Prepare README, changelog, and release documentation
```

Labels:

```text
type:docs
area:documentation
```

Acceptance criteria:

- [ ] Quick start added.
- [ ] XeLaTeX requirement documented.
- [ ] Current scope documented.
- [ ] Future scope distinguished from current support.
- [ ] `CHANGELOG.md` contains `0.1.0`.
- [ ] Licence documented.

### Issue 11

```text
[release] Publish v0.1.0
```

Labels:

```text
type:release
area:build
area:documentation
```

Acceptance criteria:

- [ ] All release-blocking issues closed.
- [ ] CI passes on `main`.
- [ ] Version strings updated.
- [ ] Tag `v0.1.0` pushed.
- [ ] GitHub Release created.
- [ ] Example PDFs attached.
- [ ] Milestone closed.

## 5. Issue-writing rule

Every implementation issue should answer:

1. What problem or deliverable does this issue cover?
2. What is included?
3. What is excluded?
4. What files are likely affected?
5. What observable conditions prove completion?
6. What parent issue and milestone does it belong to?

A good issue is small enough to implement on one focused branch. If it becomes `L`, split it.
