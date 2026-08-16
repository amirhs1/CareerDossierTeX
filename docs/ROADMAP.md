# CareerDossierTeX Roadmap

Release scope, phase boundaries, and explicit non-goals — what each release is
for, and what it deliberately excludes. **Nothing here is a support statement.**
A feature described in a planned phase does not exist yet; `README.md` and
[`API.md`](API.md) describe what is actually released.

## Product direction

CareerDossierTeX is a reusable LuaLaTeX toolkit for creating consistent career documents from shared profile data.

The project follows incremental releases. Each implementation issue should
produce one complete, documented, and tested vertical slice. Tests are added
under `tests/` with the behavior they protect, not collected into a separate
test pass at the end of a milestone.

> **Current status:** `v0.8.0 — Semantic Structure and Tagged Output` is
> released. `v0.3.0` is dropped. The next planned release is `v0.9.0 —
> Documentation, Examples, and Release Readiness`, followed by `v1.0.0 — Stable
> Public API`.
>
> **Renumbered on 2026-08-01.** `v0.7.0` was numbered `v0.6.1` until then. It
> adds new public API — the `medium` option and new spacing tokens — which is a
> minor release under Semantic Versioning, not a patch; it also renames public
> design tokens and retunes calibrated values, so documents reflow. The former
> `v0.7.0 — Examples and Templates Revision` moved to `v0.8.0`. See
> [issue #205](https://github.com/amirhs1/CareerDossierTeX/issues/205).
>
> **Reorganised on 2026-08-05.** By then `v0.8.0` held eleven structure and
> semantics issues against three examples issues, so its title no longer
> described its contents. It was retitled `v0.8.0 — Semantic Structure and
> Tagged Output`, and the examples and documentation work moved into `v0.9.0`,
> retitled from `Documentation, Packaging, and Release Readiness` to
> `Documentation, Examples, and Release Readiness`. `v1.0.0` moved from
> `Phase 8` to `Phase 9` to make room for the `v0.9.0` phase section, which this
> document previously did not have. `v1.1.0 — Themes and Font Families` was
> closed empty; its deferred work has no milestone. See
> [issue #279](https://github.com/amirhs1/CareerDossierTeX/issues/279).

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
| `v0.7.0` | Page furniture placement, the `medium` output-context option, and spacing ownership | Released |
| `v0.8.0` | Semantic structure, tagged-output metadata, and the public typography and colour roles | Released |
| `v0.9.0` | Documentation set, revised examples, PDF manual, and CTAN archive | Planned |
| `v1.0.0` | Stable, documented public API | Planned |
| `v1.1.0` | Themes and font families | **Closed empty — 2026-08-05** |

Repository milestones are tracked on the GitHub milestones page:

```text
https://github.com/amirhs1/CareerDossierTeX/milestones
```

## Phase numbering

The Project's `Phase` field is the canonical numbering; the headings below
follow it. Every shipped major or minor release has a phase of its own. A patch
release does not — its issues carry the phase of the minor release they correct,
which is why `v0.1.1` and `v0.2.1` appear in the release overview above but have
no phase heading here.

A release that never ships has no phase number at all. `v0.3.0` **held**
`Phase 3` and gave it up when it was dropped, and the Project reused the slot for
`v0.4.0`; `v1.1.0` was closed empty before it had an option to give up. Both
therefore appear unnumbered. See `docs/NAMING-CONVENTION.md` §10.

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
| `Phase 6: v0.7.0` | `Phase 6 — Spacing Ownership and Output Medium` |
| `Phase 7: v0.8.0` | `Phase 7 — Semantic Structure and Tagged Output` |
| `Phase 8: v0.9.0` | `Phase 8 — Documentation, Examples, and Release Readiness` |
| `Phase 9: v1.0.0` | `Phase 9 — Stable API` |
| `v1.1.0` **(closed empty, unnumbered)** | *(none — never had an option)* |

The two patch releases have no heading of their own: `v0.1.1` carries
`Phase 1 — Industry` and `v0.2.1` carries `Phase 2 — Academic`, alongside the
minor release each one corrects. `Phase 0 — Inventory` runs the other way — it is
the pre-release baseline and has no milestone.

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

Delivered scope and this release's criteria are recorded in the closed
[`v0.6.0` milestone](https://github.com/amirhs1/CareerDossierTeX/milestone/9),
[epic #137](https://github.com/amirhs1/CareerDossierTeX/issues/137), and its
[`CHANGELOG.md` entry](../CHANGELOG.md#060---2026-07-30).

### Agreed defaults and their measured cost

Defaults are per class, not uniform, because document conventions differ: the
résumé is `11pt` at `margin=narrow`, and the CV, letter, and statement classes
are `12pt` at `margin=normal`. The measured characters per line for each
combination live in [`ARCHITECTURE.md`](ARCHITECTURE.md#careerdossier-tokenssty),
which records the `\textwidth` values and the counting method alongside them.

The prose classes take `12pt` specifically to control measure: at `normal`,
`11pt` runs longer than the conventional 45–90 guidance while `12pt` lands just
inside it. Capping `\textwidth` from a
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

## Phase 6: `v0.7.0 — Page Furniture, Output Medium, and Spacing Ownership`

### Goal

Reclaim ownership of vertical placement and spacing for the calibrated design
system released in `v0.6.0`, make page furniture selectable by output context,
and retune the vertical-rhythm ratios once every gap is owned by a token.
Several vertical dimensions had been decided by a third-party default or a
hard-coded constant rather than by the design system meant to own them —
`geometry`'s header and folio placement, LaTeX's single `topsep`, a
hard-coded bibliography inter-entry gap, LaTeX Lab's tagged-path list default,
and headers unable to escape the prose `\parskip` among them — and each is
handed back to its owning token, with the vertical-rhythm ratios retuned once
every gap can express itself. Rendered output therefore moves in two ways: it
is *corrected* where a spacing decision was never the design system's to begin
with, and it *reflows by design* where the ratios are retuned; no type-scale
step or margin preset changes value. The release also adds a `medium`
(`screen`/`print`) class option, three header-composition commands, and a
renamed and split vertical-spacing token vocabulary, every rename and
retirement source-compatible for a document that does not read a token by
name.

### Included

Delivered scope and this release's criteria are recorded in the closed
[`v0.7.0` milestone](https://github.com/amirhs1/CareerDossierTeX/milestone/10),
[epic #182](https://github.com/amirhs1/CareerDossierTeX/issues/182), and its
[`CHANGELOG.md` entry](../CHANGELOG.md#070---2026-08-04).

### Explicit non-goals

- any change to the *value* of a type-scale step or a margin preset. The
  vertical-rhythm ratios *are* retuned in this release, but only under #206 and
  only against its stated design rules; a ratio changed incidentally by any
  other issue here is out of scope. The list-edge split and the token renames
  are mechanism and naming changes that preserve every rendered gap;
- colour themes. `theme=monochrome` remains fixed, and `medium` is deliberately
  a separate axis from colour — the two must not be conflated;
- per-class furniture customization, user-supplied header or footer content,
  and page-numbering format options;
- widening `medium` beyond page furniture (hyperlink colour, PDF metadata, or
  viewer preferences) in this release;
- the extracted reading order of a bibliography's entry numbers (#199), a
  follow-up from #196. Once the entry gap closes, the default `pdftotext`
  heuristic groups the entry numbers ahead of the entry text. The PDF geometry
  is correct — each label shares a baseline with its entry, and
  `pdftotext -layout` reads in source order — and fixing it means changing
  `biblatex` label geometry, which #196 lists as a non-goal.

## Phase 7: `v0.8.0 — Semantic Structure and Tagged Output`

### Goal

Complete the semantic structure and the tagged-output metadata, and settle the
public typography and colour roles, before the `v1.0.0` API freeze. The
released output had carried less structure than it appeared to — no document
from any of the four classes contained an `/H1`, `/Lang` was absent from the
default build path, and the derived `/Title` never reached a viewer's window —
and three public roles were still unsettled: the `Title` collision between the
type scale and the entry primitives, entry metadata's de-emphasis role, and
several semantic colour tokens declared but never consumed. Two further
defects were corrected rather than chosen: links had no visible affordance
under `medium=screen`, and `emergencystretch` was set in more than one place
with no named token.

### Included

Delivered scope and this release's criteria are recorded in the closed
[`v0.8.0` milestone](https://github.com/amirhs1/CareerDossierTeX/milestone/11),
[epic #281](https://github.com/amirhs1/CareerDossierTeX/issues/281), and its
[`CHANGELOG.md` entry](../CHANGELOG.md#080---2026-08-12).

### Explicit non-goals

- PDF/UA-2 conformance claims. Tagged structure remains opt-in through
  `\DocumentMetadata{tagging=on}`, and veraPDF validation runs on the scheduled
  workflow, not on the per-PR tagging job.
- colour themes and named font families. Deferred on 2026-07-22 with no
  milestone; `v1.1.0 — Themes and Font Families` was closed empty on 2026-08-05
  ([issue #120](https://github.com/amirhs1/CareerDossierTeX/issues/120)).
- a `templates/` folder. Proposed in
  [issue #280](https://github.com/amirhs1/CareerDossierTeX/issues/280) and
  deliberately unmilestoned; the release that carries it is undecided.

## Phase 8: `v0.9.0 — Documentation, Examples, and Release Readiness`

### Goal

Consolidate the documentation set, revise and extend the examples, build the PDF
manual, and configure the CTAN release archive.

### Scope

Documentation:

- split `docs/ATS-EXTRACTION.md` into its charter and the documents that own the
  rest of its material (#262);
- give each duplicated mechanism explanation one canonical home (#259);
- document how to install the classes (#261);
- correct two source comments that document rejected behaviour (#275);
- decide whether maintainer-tooling fixes belong in `CHANGELOG.md`, which #245
  currently has no entry for (#260).

Examples:

- review each example under `examples/` for currency against the calibrated
  token system, consistency with the others, and whether it still demonstrates
  its intended feature clearly;
- add a longer, multi-page `cv-bibliography` example where the current fixture is
  too thin to show real behavior (#197);
- demonstrate tagging and contact labels in a shipped example (#273).

Release readiness:

- build a PDF manual and ship it with its source (#263) — the one hard blocker
  on a CTAN submission;
- configure `l3build ctan` and inspect the resulting archive (#264);
- lint that every Work file declares the same version and date (#258).

Tracked under
[milestone `v0.9.0`](https://github.com/amirhs1/CareerDossierTeX/milestone/12)
and [epic #283](https://github.com/amirhs1/CareerDossierTeX/issues/283).

## Phase 9: `v1.0.0 — Stable Public API`

### Goal

Declare a stable and fully documented interface.

### Definition of `1.0.0`

- public commands, options, keys, and environments are documented;
- supported engines and languages are tested;
- migration paths exist for renamed features;
- deprecation policy is documented;
- release ZIP works on Overleaf;
- examples and manual are complete;
- CI verifies all supported configurations;
- manual screen-reader passes are recorded for VoiceOver on the statement
  fixture (#274) and NVDA on Windows (#96), so both sit together as one
  release criterion.

Tracked under
[milestone `v1.0.0`](https://github.com/amirhs1/CareerDossierTeX/milestone/5)
and [epic #285](https://github.com/amirhs1/CareerDossierTeX/issues/285).

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
directory. Every shared package and every document class carries committed
regression coverage — no module is exempt — alongside the extraction, layout,
tagging, bibliography, and lint suites; extend the existing file for a module
with the behavior each future change adds. `docs/ARCHITECTURE.md` ("Testing
strategy") holds the current count and its per-module split.

## Engineering work (tracked as issues)

The live issue and Project metadata now follow the continuous-testing policy:

- CTAN packaging via `l3build ctan`, and the PDF manual a submission requires —
  `v0.9.0`, under #264 and #263. Whether the manual is handwritten or generated
  from a `.dtx` is decided there; `.dtx` is not a CTAN requirement.
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
