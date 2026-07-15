# CareerDossierTeX Roadmap

## Product direction

CareerDossierTeX is a reusable XeLaTeX toolkit for creating consistent career documents from shared profile data.

The project follows incremental releases. Each implementation issue should
produce one complete, documented, and tested vertical slice. Tests are added
under `tests/` with the behavior they protect, not collected into a separate
test pass at the end of a milestone.

> **Current status:** Pre-release development toward `v0.1.0`.

## Release overview

| Version | Release goal | Status |
|---|---|---|
| `v0.1.0` | English industry résumé and cover letter | In development |
| `v0.2.0` | Academic CV, academic letter, and bibliography support | Planned |
| `v0.3.0` | Farsi, bilingual, and right-to-left support | Planned |
| `v0.4.0` | Statement classes and broader customization | Planned |
| `v1.0.0` | Stable, documented public API | Planned |

Repository milestones are tracked on the GitHub milestones page:

```text
https://github.com/amirhs1/CareerDossierTeX/milestones
```

## Phase 0: inventory and baseline

### Goal

Understand and preserve the strongest existing résumé and cover-letter implementations before refactoring.

### Deliverables

- select baseline résumé and letter designs;
- compile and save reference PDFs;
- record dependencies and public commands;
- identify duplicated code;
- begin `docs/MIGRATION.md`;
- define the initial public interface in `docs/API.md`.

### Completion condition

The project has a documented baseline against which later changes can be compared.

## `v0.1.0 — English Industry Dossier`

### Goal

Publish the smallest useful CareerDossierTeX release.

### Included

- XeLaTeX;
- English;
- US Letter paper;
- monochrome theme;
- one résumé layout;
- one industry cover-letter layout;
- shared profile metadata;
- required-field validation;
- optional-field separator handling;
- package/class regression coverage for implemented Phase 1 behavior;
- smoke, error-path, layout-stress, and extraction fixtures under `tests/`;
- example résumé and letter;
- local `latexmk` builds;
- GitHub Actions compilation;
- release documentation.

### Explicit non-goals

- academic CV;
- bibliography or Biber;
- Farsi or bilingual documents;
- RTL layout;
- statement classes;
- A4 paper;
- color themes;
- icons;
- CTAN packaging.

### Release criteria

- résumé and letter compile locally with XeLaTeX;
- both reuse the same profile file;
- missing required metadata produces a clear error;
- missing optional fields do not leave empty separators;
- extracted résumé text follows logical reading order;
- every implemented behavior has the relevant committed test under `tests/`;
- the accumulated regression, smoke, layout, and extraction suites pass;
- CI builds both examples;
- README and API documentation match actual behavior;
- tag and GitHub Release `v0.1.0` are published.

## `v0.2.0 — Academic Dossier`

### Goal

Extend the shared foundation to academic applications.

### Planned deliverables

- `careerdossier-cv.cls`;
- academic cover-letter family;
- `careerdossier-biblatex.sty`;
- optional Biber integration;
- manual publication entries;
- multi-page CV support;
- running headers and page numbers;
- Scholar and ORCID fields;
- long-entry and page-break tests added with the academic features they cover.

### Release criteria

- long CVs page-break safely;
- bibliography support remains optional;
- a CV without `biblatex` still builds;
- a Biber example builds through `latexmk`;
- academic and industry documents reuse the same profile.

## `v0.3.0 — Farsi and Bilingual Support`

### Goal

Add multilingual and mixed-direction documents without duplicating the class system.

### Planned deliverables

- `language=english|farsi|bilingual`;
- `main-language=english|farsi`;
- translation tables;
- Farsi font configuration;
- RTL and mixed-direction helpers;
- mirrored dates, bullets, and layout components;
- LTR handling for email, URL, ORCID, and Latin numbers;
- Farsi and bilingual examples;
- direction and glyph tests.

### Architectural rule

Extend existing classes:

```latex
\documentclass[language=farsi]{careerdossier-cv}
```

Do not create separate language-specific classes unless a future document model is genuinely different.

## `v0.4.0 — Statements and Customization`

### Goal

Support additional application documents and broader visual configuration.

### Planned deliverables

- `careerdossier-statement.cls`;
- research, teaching, diversity, artist, and general statements;
- A4 paper;
- additional print and color themes;
- font presets;
- optional icons;
- additional stress tests and documentation.

## `v1.0.0 — Stable Public API`

### Goal

Declare a stable and fully documented interface.

### Definition of `1.0.0`

- public commands, options, keys, and environments are documented;
- supported engines and languages are tested;
- migration paths exist for renamed features;
- deprecation policy is documented;
- release ZIP works on Overleaf;
- examples and manual are complete;
- CI verifies all supported configurations.

## Continuous testing policy

Testing is part of each implementation issue and pull request:

1. define the observable behavior and its test before implementation;
2. place automated sources, fixtures, runners, and baselines under `tests/`;
3. write the test first when practical, or alongside the first usable
   implementation when a pre-implementation run is not possible;
4. run the focused test plus affected existing suites before merge;
5. rerun the accumulated suite at release time without deferring new feature
   coverage to release preparation.

Dedicated test issues are reserved for shared harness work, cross-cutting quality
improvements, or explicit legacy test debt. They are not a substitute for tests
required by a feature's acceptance criteria.

The repository uses an `l3build` regression harness (`build.lua`, run with
`l3build check`) whose sources and baselines live under `tests/regression/`, so
all test material remains under `tests/` with no top-level `testfiles/`
directory. Committed regression coverage for the already-merged Phase 1
packages (base, components, theme, and the non-visual parts of typography) is in
place alongside the extraction round-trip fixture; extend it with the behavior
each future change adds.

## Engineering work (tracked as issues)

The live issue and Project metadata now follow the continuous-testing policy:

- Establish the `l3build` regression harness (`build.lua`,
  `tests/regression/`) during active Phase 1 work in
  [issue #25](https://github.com/amirhs1/CareerDossierTeX/issues/25). Add each
  new regression with the behavior it protects.
- Backfill committed coverage for the already-merged Phase 1 modules in
  [issue #10](https://github.com/amirhs1/CareerDossierTeX/issues/10). Résumé and
  letter tests remain owned by their feature issues rather than this debt item.
- CTAN packaging via `l3build ctan`; decide handwritten vs `.dtx` — `v1.0.0`.
- Revisit tagged PDF / PDF-UA once XeTeX supports real interword spaces —
  `v0.4.0`.

## Scope-control rule

A feature may enter a release only when:

1. its public behavior is defined;
2. a minimal example exists;
3. it is documented;
4. its repeatable or automated test was added with the implementation under
   `tests/`;
5. it does not require claiming unsupported configurations.

Attractive but nonessential features belong in the backlog until the current milestone is complete.
