# CareerDossierTeX Roadmap

## Product direction

CareerDossierTeX is a reusable LuaLaTeX toolkit for creating consistent career documents from shared profile data.

The project follows incremental releases. Each implementation issue should
produce one complete, documented, and tested vertical slice. Tests are added
under `tests/` with the behavior they protect, not collected into a separate
test pass at the end of a milestone.

> **Current status:** `v0.6.0 — Calibrated Type Scale and Rhythm` is released.
> `v0.3.0` is dropped. The next planned release is `v0.6.1 — Page Furniture
> Placement and Output Medium`, followed by `v1.0.0 — Stable Public API`.

## Release overview

| Version | Release goal | Status |
|---|---|---|
| `v0.1.0` | English industry résumé and cover letter | Released |
| `v0.1.1` | English industry dossier plus metadata and build corrections | Released |
| `v0.2.0` | Academic CV, academic letter, and bibliography support | Released |
| `v0.2.1` | PDFKit text-extraction correction | Released |
| `v0.4.0` | LuaLaTeX transition and opt-in tagged-PDF preview | Released |
| `v0.3.0` | Farsi, bilingual, and right-to-left support | **Dropped — 2026-07-16** |
| `v0.5.0` | Statement classes and broader customization | Released |
| `v0.6.0` | Calibrated type scale, vertical rhythm, and page geometry | Released |
| `v0.6.1` | Page furniture placement and the `medium` output-context option | Planned |
| `v1.0.0` | Stable, documented public API | Planned |

Repository milestones are tracked on the GitHub milestones page:

```text
https://github.com/amirhs1/CareerDossierTeX/milestones
```

## Phase numbering

The Project's `Phase` field is the canonical numbering; the headings below
follow it. A dropped release does not retain a phase number, which is why
`v0.3.0` appears here as an unnumbered section. See
`docs/NAMING-CONVENTION.md` §10.

The two forms differ deliberately — this document keys each phase to its
version, the Project uses a short label — so they cross-walk as follows:

| This document | Project `Phase` option |
|---|---|
| `Phase 0: inventory and baseline` | `Phase 0 — Inventory` |
| `Phase 1: v0.1.0` | `Phase 1 — Industry` |
| `Phase 2: v0.2.0` | `Phase 2 — Academic` |
| `v0.3.0` **(dropped, unnumbered)** | *(none — slot reused)* |
| `Phase 3: v0.4.0` | `Phase 3 — Engine and Accessibility` |
| `Phase 4: v0.5.0` | `Phase 4 — Expansion` |
| `Phase 5: v0.6.0` | `Phase 5 — Calibration` |
| `Phase 6: v0.6.1` | `Phase 6 — Furniture and Output Medium` |
| `Phase 7: v1.0.0` | `Phase 7 — Stable API` |

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

## Phase 1: `v0.1.0 — English Industry Dossier`

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

## Phase 2: `v0.2.0 — Academic Dossier`

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
> **No phase number:** this section is deliberately unnumbered. The Project's
> `Phase` field reused the `Phase 3` slot for the engine and accessibility work
> that shipped as `v0.4.0`, and a dropped release does not retain a phase
> number (see `docs/NAMING-CONVENTION.md` §10). Refer to this section by name,
> never by number.
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

## Phase 3: `v0.4.0 — LuaLaTeX Transition and Tagged-PDF Preview`

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

## Phase 4: `v0.5.0 — Statements and Customization`

### Goal

Support additional application documents and broader visual configuration.

### Planned deliverables

- `careerdossier-statement.cls`;
- one class with `research`, `teaching`, `teaching-philosophy`, `diversity`,
  `artist`, and `purpose` types;
- A4 paper;
- a cross-class `bodyfont=serif|sans` option with the current serif default;
- additional stress tests and documentation.

The maintainer deferred color themes, named or per-role font combinations,
optional icons, and the Windows/NVDA reading-order check on 2026-07-22. Their
future milestone remains undecided; they are not release blockers for
`v0.5.0`.

## Phase 5: `v0.6.0 — Calibrated Type Scale and Rhythm`

### Goal

Replace the mixture of per-class settings and inherited `article` defaults with
one shared, proportional design system, driven by two public inputs —
`fontsize` and `margin` — applied identically by every document class.

### Governing rules

1. Every type size is a ratio of the body size, snapped to whole points.
2. Every vertical gap is a ratio of the body baseline.
3. Therefore `10pt`, `11pt`, and `12pt` are one design at three scales, not
   three differently proportioned designs.

### Included

- `careerdossier-tokens.sty`: the single source of truth for the type scale,
  vertical rhythm, rule weight, list metrics, and page geometry;
- `fontsize` (`10pt`, `11pt`, `12pt`) and `margin` (`normal`, `narrow`) on all
  four classes; `fontsize` is new on the letter and statement classes, `12pt`
  is new everywhere;
- per-class defaults rather than one uniform default: the résumé stays compact
  (`11pt`, `narrow`), while the CV, letter, and statement default to `12pt` at
  the shared `normal` margin to
  keep prose line length within a readable range at a conventional margin;
- one shared page-furniture design (running header from page two, `Page N of
  M` folio) across all four classes, with the folio suppressed on single-page
  documents;
- a keep-together page-break policy for section headings, entry headings, and
  bullet groups;
- reference PDFs for every `fontsize` × `margin` combination, across all four
  document types.

### Agreed defaults and their measured cost

Defaults are per class, not uniform, because document conventions differ.
Characters per line are measured from extracted text of full prose lines in
TeX Gyre Termes on US Letter:

| Class | `fontsize` | `margin` | Characters per line |
|---|---|---|---|
| résumé | `11pt` | `narrow` | 118–127 |
| CV | `12pt` | `normal` | 93–101 |
| letter | `12pt` | `normal` | 93–101 |
| statement | `12pt` | `normal` | 93–101 |

The prose classes take `12pt` specifically to control measure: at `normal`,
`11pt` yields about 102–113 characters per line, outside the conventional
45–90 guidance, while `12pt` lands just inside it. Capping `\textwidth` from a
target measure was considered and rejected — reaching 80 characters at `11pt`
needs side margins near 1.68 in, which no career-services guidance endorses.

**Known accepted limitation:** the résumé default is the longest measure in the
project, accepted for one-page capacity rather than overlooked. It is stated
for authors in `docs/API.md`, with the rationale in `docs/ARCHITECTURE.md`.

### Explicit non-goals

- color themes, named or per-role font combinations, and icons — still
  deferred, undecided future milestone (see Phase 4);
- any change to public content commands, key names, contact rendering,
  colours, or fonts;
- a language- or direction-abstraction option (see the dropped
  `v0.3.0 — Farsi and Bilingual Support` section).

### Removed

- the `density` (`compact`/`standard`) class option, replaced by the
  calibrated, proportional rhythm derived from `fontsize`.

### Release criteria

- no `.sty` or `.cls` file mentions `density`, and no file under `examples/`
  passes it as an option — `grep -rnE 'density[[:space:]]*=' *.sty *.cls
  examples/` returns nothing. Match on `density=`, not the bare word:
  `examples/statements/artist-statement.tex` uses "density" as ordinary
  English prose;
- the résumé and CV classes reject `density=` with their actionable
  unknown-option message, pinned by `tests/smoke/resume-density-option.tex`
  and `tests/smoke/cv-density-option.tex` at the class layer and
  `tests/regression/tokens-errors.lvt` at the package layer. These fixtures
  are the enforcement of the removal and are expected to name the option;
  mentions in `CHANGELOG.md`, `docs/MIGRATION.md`, and `docs/API.md` are
  required by the breaking-change documentation rule. Neither is an exception
  to be eliminated;
- no literal type size or structural vertical space outside
  `careerdossier-tokens.sty`;
- no `\geometry` call outside the shared geometry primitive;
- all four classes accept `fontsize` and `margin` and reject unsupported
  values with an actionable message;
- every type size in the output is a whole number of points;
- bullets align with section headings, section rules, and entry titles;
- a one-page document carries no folio; a multi-page document carries a folio
  throughout and a running header from page two;
- tagged builds still mark furniture and the section rule as artifacts;
- CI builds every example at all three `fontsize` values.

Tracked under
[milestone `v0.6.0`](https://github.com/amirhs1/CareerDossierTeX/milestone/9)
and [epic #137](https://github.com/amirhs1/CareerDossierTeX/issues/137).

## Phase 6: `v0.6.1 — Page Furniture Placement and Output Medium`

### Goal

Correct where page furniture sits and make it selectable by output context,
without touching the calibrated design system released in `v0.6.0`.

This is a **non-breaking patch release**. No type size, vertical-rhythm token,
margin preset, or geometry dimension that affects the text block changes, so
**no document reflows**. The only new public surface is one additive class
option whose default reproduces current output exactly.

### Included

- furniture placement derived from the resolved margin rather than from
  `geometry` package defaults: `headheight`, `headsep`, and `footskip` are
  computed so that the running header is vertically centred in the top margin
  and the `Page N of M` folio is vertically centred in the bottom margin, at
  every `fontsize` × `margin` combination and on both `letter` and `a4`;
- a `headheight` large enough for the furniture step of the type scale at every
  `fontsize`, replacing the inherited fixed `12pt`;
- a public `medium` option (`screen`, `print`) on all four document classes,
  defaulting to `print`: `print` keeps today's behaviour (running header from
  page two, folio throughout, both suppressed on a single-page document) and
  `screen` emits no running header and no folio on any page. **This is a public
  API proposal awaiting maintainer sign-off** on the option name and on whether
  `screen` suppresses the running header as well as the folio; nothing here is
  implemented or supported until that decision lands;
- an actionable class error for an unsupported `medium` value, consistent with
  `fontsize`, `margin`, `paper`, and `bodyfont`;
- regression, smoke, and layout coverage for the resolved furniture metrics,
  both `medium` values, and the unknown-value error;
- this roadmap renumbering and the phase-numbering convention that prevents it
  from drifting again.

### Explicit non-goals

- any change to the type scale, vertical rhythm, margin presets, or any
  `careerdossier-tokens.sty` dimension that affects the text block;
- colour themes. `theme=monochrome` remains fixed, and `medium` is deliberately
  a separate axis from colour — the two must not be conflated;
- per-class furniture customization, user-supplied header or footer content,
  and page-numbering format options;
- widening `medium` beyond page furniture (hyperlink colour, PDF metadata, or
  viewer preferences) in this release.

### Release criteria

- header and folio are vertically centred in their margins at all six
  `fontsize` × `margin` combinations, on Letter and A4;
- `\textheight` and `\textwidth` are unchanged from `v0.6.0` at every
  combination;
- `medium=screen` suppresses furniture and `medium=print` retains current
  behaviour, on all four document classes;
- an unsupported `medium` value produces an actionable class error naming the
  accepted values;
- `make review-matrix` output is reviewed for both media;
- the extraction, tagging, layout, and regression suites pass;
- `docs/API.md`, `docs/ARCHITECTURE.md`, and `CHANGELOG.md` are updated;
- tag and GitHub Release `v0.6.1` are published.

Tracked under
[milestone `v0.6.1`](https://github.com/amirhs1/CareerDossierTeX/milestone/10)
and [epic #182](https://github.com/amirhs1/CareerDossierTeX/issues/182).

## Phase 7: `v1.0.0 — Stable Public API`

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
