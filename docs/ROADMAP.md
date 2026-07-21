# CareerDossierTeX Roadmap

## Product direction

CareerDossierTeX is a reusable LuaLaTeX toolkit for creating consistent career documents from shared profile data.

The project follows incremental releases. Each implementation issue should
produce one complete, documented, and tested vertical slice. Tests are added
under `tests/` with the behavior they protect, not collected into a separate
test pass at the end of a milestone.

> **Current status:** `v0.4.0 — LuaLaTeX Transition and Tagged-PDF Preview` is
> released. `v0.3.0` is dropped. The next planned release is
> `v0.5.0 — Statements and Customization`.

## Release overview

| Version | Release goal | Status |
|---|---|---|
| `v0.1.0` | English industry résumé and cover letter | Released |
| `v0.1.1` | English industry dossier plus metadata and build corrections | Released |
| `v0.2.0` | Academic CV, academic letter, and bibliography support | Released |
| `v0.2.1` | PDFKit text-extraction correction | Released |
| `v0.4.0` | LuaLaTeX transition and opt-in tagged-PDF preview | Released |
| `v0.3.0` | Farsi, bilingual, and right-to-left support | **Dropped — 2026-07-16** |
| `v0.5.0` | Statement classes and broader customization | Planned |
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

### Included

- `careerdossier-cv.cls`;
- academic cover-letter family;
- `careerdossier-biblatex.sty`;
- optional Biber integration;
- manual publication entries;
- multi-page CV support;
- running headers and page numbers;
- Scholar and ORCID fields;
- long-entry and page-break tests added with the academic features they cover;
- supported no-BibLaTeX CV, Biber-backed CV, and academic-letter examples; and
- user, contributor, API, architecture, migration, roadmap, and changelog
  documentation matched to implemented behavior.

These interfaces are released in `v0.2.0`.

### Release criteria

- long CVs page-break safely;
- bibliography support remains optional;
- a CV without `biblatex` still builds;
- a Biber example builds through `latexmk`;
- academic and industry documents reuse the same profile;
- every supported example builds locally and in CI;
- the accumulated regression, extraction, smoke, layout, and bibliography
  suites pass; and
- README and API documentation match the tagged behavior.

### Explicit non-goals

- pdfLaTeX or LuaLaTeX;
- Farsi, bilingual, or RTL documents;
- A4 paper;
- color themes, font presets, icons, or bundled fonts;
- statement classes;
- alternate bibliography or citation styles;
- automatic import from ORCID, Scholar, DOI services, or external APIs; and
- PDF/UA or broad ATS-conformance claims.

## `v0.3.0 — Farsi and Bilingual Support` **(dropped — 2026-07-16)**

> **Status:** dropped on 2026-07-16. The milestone is closed and the release is
> not planned. CareerDossierTeX is English-only, and no language-abstraction
> module exists (see `docs/ARCHITECTURE.md`). This section is retained as a
> design record, not as committed scope — nothing here may be implemented or
> documented as current.
>
> **Consequence:** mature RTL support via `bidi` was the main reason the
> project stayed XeLaTeX-only. With multilingual work dropped, that constraint
> no longer applies, which removes the structural argument against evaluating
> a LuaLaTeX migration.

### Goal

Add multilingual and mixed-direction documents without duplicating the class system.

### Deliverables if revived

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

## `v0.4.0 — LuaLaTeX Transition and Tagged-PDF Preview`

### Goal

Replace XeLaTeX with LuaLaTeX as the sole supported engine, preserving the
English public API and visual design, and add a validated opt-in tagged-PDF path
for the named fixture profiles.

This is a **breaking toolchain change**. Documents keep their classes, options,
keys, and commands; the build command changes from `latexmk -xelatex` to
`latexmk -lualatex`, and XeTeX-specific preamble code stops working.

### Included

- LuaLaTeX-only engine guard; XeLaTeX and pdfLaTeX fail early with an actionable
  diagnostic;
- removal of the XeTeX-only `\XeTeXgenerateactualtext` primitive;
- portable font resolution through `luaotfload` on macOS and pinned Linux CI;
- re-baselined visual layout and extraction against `v0.2.0`;
- `Makefile`, `l3build`, test runners, and CI migrated to LuaLaTeX;
- opt-in `\DocumentMetadata{tagging=on}` semantic structure covering headings,
  lists, links, and layout artifacts;
- validation of the four named fixtures with an independent validator and
  screen-reader reading-order checks;
- migration notes, canonical documentation, and release preparation.

### Explicit non-goals

- Farsi, bilingual, or RTL support (dropped);
- tagging enabled by default;
- any broad PDF/UA, WCAG, or ATS conformance claim for arbitrary user documents;
- public API, paper-size, or theme changes.

### Release criteria

- every supported example compiles locally and in CI under LuaLaTeX;
- XeLaTeX and pdfLaTeX produce a clear, tested engine error;
- layout and extraction are reviewed against `v0.2.0` rather than silently
  re-baselined;
- untagged output is unchanged when tagging is not enabled;
- tagged fixtures pass structure, extraction, and artifact checks, and the
  validator and screen-reader results are recorded with tool versions.
  **Status:** met for macOS. The four named profiles pass veraPDF `ua2` and a
  three-extractor round trip (section 7.1), and a maintainer VoiceOver pass on
  2026-07-20 confirmed correct reading order with all decorative and repeated
  page furniture silent (section 7.2). NVDA on Windows stays platform-deferred;
  the release documents that rather than claiming a Windows result;
- `docs/MIGRATION.md` gives XeTeX-preamble users an actionable upgrade path;
- documentation claims no more than the fixtures actually verify.

## `v0.5.0 — Statements and Customization`

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
- Tagged PDF is no longer gated on XeTeX gaining real interword spaces. The
  LuaLaTeX transition supersedes that precondition, and opt-in tagged structure
  is now in-scope for `v0.4.0` via
  [issue #28](https://github.com/amirhs1/CareerDossierTeX/issues/28), with
  validation in [issue #77](https://github.com/amirhs1/CareerDossierTeX/issues/77).
  No PDF/UA conformance is claimed.

## Scope-control rule

A feature may enter a release only when:

1. its public behavior is defined;
2. a minimal example exists;
3. it is documented;
4. its repeatable or automated test was added with the implementation under
   `tests/`;
5. it does not require claiming unsupported configurations.

Attractive but nonessential features belong in the backlog until the current milestone is complete.
